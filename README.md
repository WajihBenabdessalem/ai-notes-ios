# AI Notes iOS

Application de notes iOS (SwiftUI) enrichie de fonctionnalités IA — résumé, recherche
sémantique, chat sur ses propres notes — consommant l'API du dépôt compagnon
[`ai-notes-backend`](https://github.com/WajihBenabdessalem/ai-notes-backend) (FastAPI/Python).

Projet réalisé par [Wajih Benabdessalem](https://www.linkedin.com/in/wajihabdessalem)
dans le cadre d'une transition de Senior Software Engineer (iOS) vers l'AI Engineering — la
partie du portfolio qui combine le plus directement l'expérience iOS existante et les nouvelles
compétences IA.

## Structure

Deux dossiers, à ouvrir chacun dans son propre outil :

```
AINotesKit/     # Swift Package : Domain + Data + DI — testable en CLI (`swift test`)
AINotesApp/     # Vues + ViewModels SwiftUI — à glisser dans un projet Xcode (voir son README)
```

- **`AINotesKit`** contient toute la logique métier (modèles, cas d'usage, couche réseau) et sa
  suite de tests XCTest. Il ne dépend d'aucune UI et se teste en ligne de commande, sans Xcode.
- **`AINotesApp`** contient les vues SwiftUI et ViewModels (MVVM, `@Observable`), qui dépendent
  de `AINotesKit` comme package local. Nécessite Xcode pour être buildé (voir
  `AINotesApp/README.md` pour la mise en place en 5 minutes).

## Démarrage rapide

```bash
git clone https://github.com/<votre-user>/ai-notes-ios.git
cd ai-notes-ios

# 1. Tester la logique métier (aucun besoin d'Xcode)
cd AINotesKit
swift test

# 2. Intégrer les vues dans un projet Xcode — voir AINotesApp/README.md
```

Le backend ([`ai-notes-backend`](https://github.com/<votre-user>/ai-notes-backend)) doit
tourner en parallèle pour que l'app fonctionne réellement — voir son README pour le lancer
(`make run`, démarre sur `http://localhost:8000`).

## Architecture

```
┌──────────────────────-──-──┐        HTTP/JSON         ┌──────────────────────────┐
│        AINotesApp          │ <──────────────────────> │     ai-notes-backend     │
│    (SwiftUI, iOS 17+)      │                          │   (dépôt séparé)         │
│                            │                          └──────────────────────────┘
│    Presentation (MVVM)     │
│           ↓ dépend de      │
│  AINotesKit (SPM local)    │
│  Domain + Data + DI        │
└──────────────────────-───-─┘
```

## État de validation

| Composant     | Statut |
|---            |---     |
| `AINotesKit/` | ⚠️ Écrit et relu avec soin (architecture, patterns Swift 5.10), mais **non compilé** — aucun toolchain Swift/Xcode disponible dans l'environnement où ce projet a été généré |
| `AINotesApp/` | ⚠️ Idem — nécessite Xcode pour build & preview |

**Avant de publier ce dépôt**, ouvre `AINotesKit` dans Xcode ou lance `swift test` en CLI sur
une machine avec le toolchain Swift, et corrige toute erreur de compilation résiduelle. C'est
la seule partie du portfolio qui n'a pas pu être exécutée réellement pendant sa construction.

## Choix de conception

- **Clean Architecture** (Domain / Data / DI) : les vues ne connaissent jamais `URLSession`,
  seulement des protocoles (`NoteRepository`, `AIService`) — testable avec de fausses
  implémentations, extensible sans toucher à la présentation.
- **`@Observable`** (Observation framework, iOS 17+) plutôt que `ObservableObject`/`@Published`
  : tracking de dépendance à la propriété près, pattern recommandé par Apple.
- **Tests réseau via `URLProtocol` stub**, sans jamais toucher le réseau réel — l'équivalent
  Swift exact du `httpx.MockTransport` utilisé côté backend Python.

## Roadmap

- [ ] Authentification utilisateur
- [ ] Synchronisation hors-ligne (cache local SwiftData)
- [ ] Widget iOS "résumé du jour"
- [ ] Tests d'interface (XCUITest) sur les parcours clés

## Licence

MIT — voir [LICENSE](LICENSE).
