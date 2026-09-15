# AINotesApp — intégration Xcode

Ce dossier contient les fichiers SwiftUI de présentation (Views + ViewModels), à ajouter dans
une cible d'application iOS. Ils dépendent du package `AINotesKit` (logique métier + réseau).

> **Pourquoi pas un `.xcodeproj` fourni directement ?** Le format `.xcodeproj` est un binaire/XML
> généré et géré par Xcode ; le produire à la main hors de Xcode est fragile et risque de livrer
> un projet corrompu ou qui n'ouvre pas correctement. La procédure ci-dessous (5 minutes) donne
> un projet Xcode propre et garanti fonctionnel.

## Mise en place (une fois)

1. Ouvrez Xcode → **File > New > Project… > iOS > App**.
   - Product Name : `AINotesApp`
   - Interface : **SwiftUI**
   - Language : **Swift**
   - Décochez "Include Tests" (les tests vivent dans `AINotesKit`)

2. Ajoutez le package local comme dépendance :
   **File > Add Package Dependencies… > Add Local…**, puis sélectionnez le dossier
   `AINotesKit` (au même niveau que `AINotesApp` à la racine du dépôt). Cochez la cible
   `AINotesApp` lors de l'ajout du produit `AINotesKit`.

3. Supprimez le `ContentView.swift` et le fichier `App.swift` générés par défaut par Xcode.

4. Glissez-déposez tout le contenu de ce dossier (`AINotesAppApp.swift` et `Presentation/`)
   dans le projet Xcode (cocher "Copy items if needed" et la cible `AINotesApp`).

5. Dans `AINotesAppApp.swift`, ajustez `baseURL` :
   - Simulateur iOS → `http://localhost:8000` (fonctionne tel quel, le simulateur partage le
     réseau du Mac hôte)
   - Appareil physique → l'adresse IP locale de votre Mac sur le même Wi-Fi, ex.
     `http://192.168.1.23:8000`
   - Par défaut, iOS bloque le HTTP non chiffré (App Transport Security) : pour du développement
     local uniquement, ajoutez une exception dans `Info.plist` (`NSAppTransportSecurity` /
     `NSAllowsLocalNetworking` = `YES`), ou passez le backend en HTTPS pour un usage réel.

6. Lancez le backend ([`ai-notes-backend`](https://github.com/<votre-user>/ai-notes-backend),
   dépôt séparé — voir son README), puis buildez et lancez l'app (⌘R).

## Structure

```
AINotesAppApp.swift            # Point d'entrée @main, construit l'AppContainer
Presentation/
├── NotesList/                 # Liste des notes, création, suppression
├── NoteDetail/                # Détail d'une note + bouton "Résumer avec l'IA"
├── Chat/                      # Conversation avec l'assistant (RAG sur les notes)
└── Search/                    # Recherche sémantique dans les notes
```

## Choix de conception

- **MVVM avec `@Observable`** (Observation framework, iOS 17+) plutôt que
  `ObservableObject`/`@Published` : pattern actuel recommandé par Apple, suivi de dépendances
  plus fin (une vue ne se redessine que si la propriété qu'elle lit change réellement).
- **`@MainActor` sur chaque ViewModel** : toute mutation d'état observable par SwiftUI est
  garantie de se produire sur le thread principal, sans `DispatchQueue.main.async` manuel.
- **Aucune vue ne connaît `URLSession`** : les vues dépendent uniquement des protocoles
  `NoteRepository` / `AIService` (via `AppContainer`), ce qui permettrait d'injecter de fausses
  implémentations pour des previews SwiftUI ou des tests d'intégration côté app.
- **Un seul point de composition** (`AppContainer`) : pas de singleton global, pas de
  service locator implicite.
