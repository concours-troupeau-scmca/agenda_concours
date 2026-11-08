-- =====================================================================
-- Notification des admins quand un nouveau compte organisateur
-- a confirme son email et attend une validation.
-- Envoi via l'API Brevo, depuis la base (extension pg_net).
-- Prerequis : la cle API Brevo est enregistree dans le coffre (Vault)
-- sous le nom 'brevo_api_key' (voir le guide).
-- =====================================================================

create extension if not exists pg_net with schema extensions;

create or replace function public.notifier_admins_nouveau_compte()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  cle text;
  destinataires jsonb;
  club text;
  corps text;
begin
  -- uniquement au moment ou l'email vient d'etre confirme
  if old.email_confirmed_at is not null or new.email_confirmed_at is null then
    return new;
  end if;

  begin
    select decrypted_secret into cle
    from vault.decrypted_secrets where name = 'brevo_api_key' limit 1;

    select coalesce(jsonb_agg(jsonb_build_object('email', o.email)), '[]'::jsonb)
    into destinataires
    from public.organisateurs o
    where o.role = 'admin' and o.statut = 'valide' and o.email is not null;

    if cle is null or jsonb_array_length(destinataires) = 0 then
      return new;
    end if;

    select coalesce(nullif(o.nom_club, ''), '(nom non renseigne)') into club
    from public.organisateurs o where o.id = new.id;

    corps := '<h2>Nouveau compte organisateur</h2>'
      || '<p>Un nouveau compte attend votre validation sur l''Agenda des concours Troupeau :</p>'
      || '<ul><li><strong>Club :</strong> ' || replace(replace(coalesce(club, ''), '<', '&lt;'), '>', '&gt;') || '</li>'
      || '<li><strong>Email :</strong> ' || replace(replace(coalesce(new.email, ''), '<', '&lt;'), '>', '&gt;') || '</li></ul>'
      || '<p>Pour le valider ou le refuser, connectez-vous au site, menu <strong>Administration</strong>, onglet <strong>Comptes</strong>.</p>'
      || '<p><a href="https://concours-troupeau-scmca.github.io/agenda_concours/#admin">Ouvrir l''administration</a></p>';

    perform net.http_post(
      url := 'https://api.brevo.com/v3/smtp/email',
      headers := jsonb_build_object('api-key', cle, 'Content-Type', 'application/json', 'accept', 'application/json'),
      body := jsonb_build_object(
        'sender', jsonb_build_object('name', 'Agenda des concours Troupeau', 'email', 'scmca.concours.troupeau@gmail.com'),
        'to', destinataires,
        'subject', 'Nouveau compte organisateur a valider - ' || coalesce(club, ''),
        'htmlContent', corps
      )
    );
  exception when others then
    -- une notification ratee ne doit jamais bloquer l'inscription
    raise warning 'notification admins impossible : %', sqlerrm;
  end;
  return new;
end $$;

drop trigger if exists notifier_admins on auth.users;
create trigger notifier_admins
  after update of email_confirmed_at on auth.users
  for each row execute function public.notifier_admins_nouveau_compte();
