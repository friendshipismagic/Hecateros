# Hécatéros

>Dieu de l'hécatéris, danse utilisant rapidement les mains…

* [Les tags](#les-tags)
* [Configuration](#configuration)
* [TODO](#todo)


Hécatéros repose sur un canal IRC et récupère les liens qui y sont posté. Il affiche une interface web pour les parcourir.

Pour plus de *privacy*, les URL des canaux dans l'interface web ne seront pas nominatives mais seront de la forme
`https://hecateros.example.org/c/UUID`.


## Les tags

Pour mieux aider à catégoriser les liens postés, un système de tags est disponible (ou bientôt disponible, suivant votre continuum spatio-temporel).

* Soit le bot prend ce qu'il trouve comme tags et les ajoute à sa base de données.
* Soit le bot fait correspondre les tags à une liste pré-définie (mais extensible) et dans ce cas-là refusera poliment les tags non-conformes mais prendra
    les bons tags.

Cela permettra une recherche par tags dans l'interface web, voir une commande spéciale pour faire apparaître les 5 derniers liens correspondant à tel tag.

Les tags sont insensibles à la casse et idéalement ne comporteraient qu'un seul mot.

Exemples de syntaxe possible :

1. `< Theophane> https://example.org #exemple,w3c#`
2. `< Theophane> Hey checkez ce lien : https://example.org/foobarlol #exemple, w3c#`

Possible façon de faire pour les URL sans tags: 

1. Soit on la stock pas.
2. Soit on la stock sans tags, et si elle réapparaît avec tags, on met juste à jour les tags.


## Configuration

Les fichiers de configuration se situent dans le dossier `config/` à la racine du projet.  
Il est prévu de pouvoir y inclure plusieurs options comme ajouter ou retirer un prefix de protocol, ou d'empêcher certains liens
(sourcer un fichier de blacklist ?). Ces options-là seront également fournies au runtime par les fonctions appropriées.

## TODO

- Core
  - [x] Changesets des schémas
  - [x] Normalisation des tags / canaux (majuscule)
  - [x] Pipeline irc → core
  - [ ] Mise à jour des tags par repost du même lien
- Web
  - [x] Pipeline core → web
  - [x] Gérer le tri par lien
  - [ ] Interface d'administration
    - [ ] Supprimer des liens
    - [ ] Ajouter / supprimer des filtres
- IRC
  - [x] Révision du système de modules.
  - [x] Répondre à un invite
  - [x] Insérer l'user qui invite comme admin du chan ←
  - [ ] Interface d'administration
    - [ ] Publier une feature pour ExIrc pour faire des WHOIS
    - [ ] Pouvoir authentifier des admins, en ayant comme premier admin la personne qui invite le bot
      - [ ] Pouvoir rajouter des admins
    - [ ] Pouvoir ajouter / supprimer des filtres

