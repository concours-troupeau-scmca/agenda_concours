# Agenda des concours Troupeau

Calendrier commun des concours de chiens de troupeau, proposé à la Société Canine Midi Côte d'Azur (SCMCA). Les clubs organisateurs y déposent leurs projets de concours et envoient leurs demandes à la SCMCA. Le calendrier public n'affiche que les concours validés.

- **Adresse du site** : https://concours-troupeau-scmca.github.io/agenda_concours/
- **Statut** : phase de test (voir la page « Mentions légales » du site)
- **Contact** : scmca.concours.troupeau@gmail.com

> Ce fichier ne contient **aucun mot de passe ni aucune clé secrète**. Le dépôt GitHub est public : ne jamais y ajouter de secret.

---

## 1. Comment le site fonctionne

| Élément | Service | Rôle |
|---|---|---|
| Pages du site | **GitHub Pages** | Héberge `index.html` et le dossier `img` |
| Base de données et comptes | **Supabase** (données à Paris) | Stocke les comptes, les fiches organisateurs, les concours et les listes |
| Envoi des mails | **Brevo** | Mails de confirmation, de mot de passe oublié et notifications aux admins |
| Réveil de la base | **cron-job.org** | Interroge la base tous les jours pour éviter la mise en pause du plan gratuit Supabase |

Tous les comptes de service sont rattachés à l'adresse **scmca.concours.troupeau@gmail.com**. Les mots de passe et clés secrètes sont rangés dans le gestionnaire de mots de passe du projet, jamais dans ce dépôt.

### Les rôles sur le site

- **Visiteur** : consulte le calendrier (liste, vue mensuelle, filtres). Aucun compte nécessaire.
- **Organisateur** : crée un compte, remplit sa fiche club, puis dépose et gère **ses propres** concours, une fois validé par un admin. Connecté, il voit aussi les concours **provisoires** des autres clubs (calendrier des prévisions).
- **Admin** : valide ou refuse les comptes, nomme d'autres admins, gère les listes (épreuves, couleurs, championnats, juges) et peut corriger n'importe quel concours.

La sécurité est gérée dans la base elle-même : un compte non validé ne peut rien publier, et un organisateur ne peut pas modifier les concours des autres, même en bidouillant la page.

### Le parcours d'un concours

1. L'organisateur crée son concours : il est **Provisoire**, visible uniquement des organisateurs connectés. Le formulaire signale les autres concours prévus aux mêmes dates.
2. Il clique sur **« Envoyer la demande à la SCMCA »** : la SCMCA reçoit un mail avec toutes les infos (copie à l'organisateur). La réponse de la SCMCA arrive directement chez l'organisateur.
3. Après réception de la validation par mail, l'organisateur passe le concours en **Validé SCMCA** : il apparaît sur le calendrier public.
4. En cas d'annulation, statut **Annulé** : le concours reste visible, barré.

L'adresse qui reçoit les demandes se règle dans Administration, onglet **Paramètres**.

---

## 2. Les fichiers du dépôt

| Fichier | Contenu |
|---|---|
| `index.html` | Le site complet (pages, style et fonctionnement) |
| `img/` | Médaille de la SCMCA, icône de l'onglet, photo d'accueil |
| `schema.sql` | Création complète de la base (tables, sécurité, listes de départ, couleurs) |
| `notifications.sql` | Notification des admins quand un nouveau compte attend une validation |
| `maj-demandes-scmca.sql` | Demandes de concours à la SCMCA, paramètres, concours provisoires cachés du public |
| `maj-couleurs.sql` | Ancienne mise à jour (couleurs des familles). Inutile pour une installation neuve, déjà incluse dans `schema.sql` |
| `README.md` | Ce guide |

---

## 3. Administration au quotidien

### Valider un nouvel organisateur
1. Les admins reçoivent un mail « Nouveau compte organisateur a valider - … » dès qu'un compte confirme son adresse.
2. Se connecter au site, menu **Administration**, onglet **Comptes**.
3. Vérifier la fiche (club, responsable, téléphone). En cas de doute, contacter le club avant de valider.
4. Mettre le statut sur **Validé** ou **Refusé**.

Un compte refusé ne peut rien publier. Repasser un compte en « Refusé » fait disparaître aussitôt ses concours du calendrier public.

### Supprimer définitivement un compte
Dans Supabase : **Authentication**, puis **Users**, ouvrir la ligne de l'utilisateur, puis **Delete user**. La fiche et les concours du compte sont supprimés avec lui. (Ce n'est pas possible depuis le site, volontairement : il faudrait y mettre la clé secrète de Supabase.)

### Nommer un admin
Administration, onglet **Comptes**, colonne **Rôle** : choisir **Admin** (le compte doit aussi être **Validé**). Il est recommandé d'avoir **au moins deux admins**.

### Gérer les listes
Administration, onglets **Épreuves**, **Championnats** et **Juges** :
- ajouter une ligne avec le bouton **Ajouter** ;
- modifier une ligne, puis cliquer sur **OK** ;
- pour retirer un élément déjà utilisé par des concours, **décocher « Actif »** plutôt que le supprimer ;
- la **couleur** de chaque famille d'épreuve (utilisée dans la vue mensuelle) se règle dans l'onglet Épreuves.

### Mettre à jour le site
Sur GitHub, dans le dépôt `agenda_concours` : **Add file**, puis **Upload files**. Déposer le nouveau `index.html` (et le dossier `img` s'il a changé), puis **Commit changes**. Le site est à jour en 1 à 2 minutes (Ctrl+F5 pour forcer le rechargement).

### Sauvegarde
Une fois par saison : Supabase, **Table Editor**, puis exporter en CSV les tables `concours` et `organisateurs`.

---

## 4. Dépannage

| Problème | Cause probable | Solution |
|---|---|---|
| Le site affiche « Impossible de charger les données » | Projet Supabase mis en pause | Tableau de bord Supabase, puis **Resume project**. Vérifier ensuite la tâche cron-job.org |
| Le mail « mot de passe oublié » ne part pas | Délai anti-abus de Supabase (environ 60 secondes par adresse) | Attendre 1 à 2 minutes avant de redemander |
| Un mail arrive en anglais | Ancien mail regroupé dans le même fil Gmail | Ouvrir le mail le plus récent du fil |
| Les mails n'arrivent pas | Spam, ou souci chez Brevo | Vérifier les spams, puis le journal d'envoi dans Brevo (Transactionnel) |
| « Envoi de mails non configuré » lors d'une demande | Clé API Brevo absente du coffre | Refaire l'étape 5.6 |
| Les admins ne reçoivent pas la notification | Clé API Brevo absente, ou adresse IP bloquée par Brevo | Voir la requête de diagnostic ci-dessous. Dans Brevo, Paramètres, Sécurité : vérifier le blocage des adresses IP inconnues |

Requête de diagnostic des notifications (Supabase, SQL Editor) :

```sql
select created, status_code, content from net._http_response order by created desc limit 5;
```

Un code 201 signifie que Brevo a accepté l'envoi.

---

## 5. Réinstallation complète (à partir de zéro)

À suivre seulement si tout est à refaire : nouveau projet Supabase, nouveau dépôt, etc.

### 5.1 Supabase : la base
1. Créer un projet sur supabase.com (région Europe, Paris).
2. **SQL Editor**, puis **New query** : coller tout `schema.sql`, puis **Run**.
3. **Project Settings**, puis **API Keys** : noter l'**URL du projet** et la **clé publique** (`sb_publishable_...`). Ne jamais utiliser la clé secrète dans le site.

### 5.2 Le site
1. Dans `index.html`, sous le commentaire « A REMPLACER », renseigner `SUPABASE_URL` et `SUPABASE_KEY` (clé publique).
2. Créer un dépôt GitHub **public**, y déposer `index.html` et le dossier `img`.
3. **Settings**, puis **Pages** : Deploy from a branch, **main**, **/ (root)**, puis **Save**.

### 5.3 Supabase : adresses du site
**Authentication**, puis **URL Configuration** :
- **Site URL** : `https://concours-troupeau-scmca.github.io/agenda_concours/`
- **Redirect URLs** : `https://concours-troupeau-scmca.github.io/**`

### 5.4 Brevo : envoi des mails
1. Compte Brevo avec l'adresse du projet. Vérifier le téléphone et déclarer l'expéditeur « Agenda des concours Troupeau » / scmca.concours.troupeau@gmail.com.
2. **Paramètres**, puis **SMTP et API**, onglet **SMTP** : noter le **Login SMTP** et générer une **clé SMTP**.
3. Dans Supabase, **Authentication**, **Emails**, onglet **SMTP Settings**, activer Custom SMTP :

| Champ | Valeur |
|---|---|
| Sender email | scmca.concours.troupeau@gmail.com |
| Sender name | Agenda des concours Troupeau |
| Host | smtp-relay.brevo.com |
| Port | 587 |
| Username | Login SMTP Brevo |
| Password | Clé SMTP Brevo |

### 5.5 Mails en français
Dans Supabase, **Authentication**, **Emails**, onglet **Templates**. Après chaque modification, cliquer sur **Save changes**.

**Confirm signup**. Objet : `Confirmez votre inscription - Agenda des concours Troupeau`

```html
<h2>Bienvenue sur l'Agenda des concours Troupeau</h2>
<p>Bonjour,</p>
<p>Vous venez de créer un compte organisateur sur l'agenda de la Société Canine Midi Côte d'Azur.</p>
<p>Pour confirmer votre adresse email, cliquez sur le lien ci-dessous :</p>
<p><a href="{{ .ConfirmationURL }}">Confirmer mon adresse email</a></p>
<p>Votre compte devra ensuite être validé par un administrateur avant que vous puissiez publier vos concours.</p>
<p>Si vous n'êtes pas à l'origine de cette inscription, ignorez simplement ce message.</p>
<p>L'équipe de l'Agenda des concours Troupeau</p>
```

**Reset password**. Objet : `Reinitialisation de votre mot de passe - Agenda des concours Troupeau`

```html
<h2>Mot de passe oublié</h2>
<p>Bonjour,</p>
<p>Vous avez demandé à changer le mot de passe de votre compte sur l'Agenda des concours Troupeau.</p>
<p><a href="{{ .ConfirmationURL }}">Choisir un nouveau mot de passe</a></p>
<p>Si vous n'avez rien demandé, ignorez ce message : votre mot de passe reste inchangé.</p>
<p>L'équipe de l'Agenda des concours Troupeau</p>
```

### 5.6 Notifications aux admins
1. Brevo, **Paramètres**, **SMTP et API**, onglet **Clés API** : générer une clé API (`xkeysib-...`).
2. Supabase, **SQL Editor** : ranger la clé dans le coffre-fort :
   ```sql
   select vault.create_secret('CLE_API_BREVO', 'brevo_api_key', 'Cle API Brevo pour les notifications admins');
   ```
3. Nouvelle requête : coller tout `notifications.sql`, puis **Run**.
4. Nouvelle requête : coller tout `maj-demandes-scmca.sql`, puis **Run** (envoi des demandes à la SCMCA).
5. Dans le site, Administration, onglet **Paramètres** : renseigner l'adresse mail de la SCMCA.

### 5.7 Premier admin
1. Créer un compte sur le site et le confirmer par mail.
2. Supabase, **SQL Editor** :
   ```sql
   update public.organisateurs set role = 'admin', statut = 'valide'
   where email = 'adresse@exemple.fr';
   ```
3. Vérifier avec : `select email, role, statut from public.organisateurs;`

### 5.8 Réveil quotidien (cron-job.org)
Créer une tâche quotidienne qui appelle :

```
https://<projet>.supabase.co/rest/v1/familles?select=id&limit=1&apikey=<cle publique>
```

Le test doit répondre **200 OK**. Activer les notifications d'échec sur l'adresse du projet.

---

## 6. Passage de relais

Pour transmettre le projet :
- [ ] Donner l'accès au gestionnaire de mots de passe (compte Gmail du projet, Supabase, GitHub, Brevo, cron-job.org).
- [ ] Nommer le ou la nouvelle responsable **admin** sur le site.
- [ ] Supabase : l'ajouter comme **Owner** de l'organisation (Organization settings, Team).
- [ ] Retirer les accès personnels qui ne servent plus (adresses perso dans Supabase, adresse de secours sur GitHub et sa connexion Google).
- [ ] Mettre à jour la page Mentions légales (responsable de la publication).

## 7. Points en attente

- Validation du projet par la SCMCA. Ensuite, mettre à jour le bandeau « phase de test » et le responsable de la publication dans `index.html` (fonction `vueMentions`).
- Compléter la liste des juges officiels.
- Nommer un deuxième admin de la SCMCA.
