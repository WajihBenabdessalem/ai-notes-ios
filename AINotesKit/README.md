# AINotesKit

Swift Package contenant toute la logique métier de l'app iOS **AINotes** : modèles de
domaine, cas d'usage, couche réseau et repositories. Architecture en couches
(Domain / Data / DI), testable indépendamment de toute interface graphique.

## Pourquoi un Swift Package séparé

Séparer la logique métier (`AINotesKit`) de l'app SwiftUI (`AINotesApp`) permet de :

- **Tester sans simulateur iOS** : `swift test` s'exécute en ligne de commande / CI, sans Xcode.
- **Isoler les dépendances réseau** : aucune vue ne parle directement à `URLSession`.
- **Réutiliser** cette logique dans une extension, un widget, ou une cible macOS/watchOS future.

## Structure

```
Sources/AINotesKit/
├── Domain/
│   ├── Note.swift                  # Modèle métier
│   ├── NoteRepository.swift        # Protocole (persistance des notes)
│   ├── AIService.swift             # Protocole (résumé, recherche, chat)
│   └── UseCases/                   # Un type par action utilisateur (callAsFunction)
├── Data/
│   ├── Networking/                 # APIClient, APIEndpoint, DTOs, gestion d'erreurs
│   └── Repositories/                # Implémentations réseau des protocoles Domain
└── DependencyInjection/
    └── AppContainer.swift          # Point de composition unique consommé par l'app

Tests/AINotesKitTests/
├── NoteTests.swift
├── StubURLProtocol.swift           # Intercepteur réseau réutilisable (pas de réseau réel)
├── APIClientTests.swift
├── RemoteNoteRepositoryTests.swift
├── RemoteAIServiceTests.swift
└── UseCaseTests.swift              # Use cases testés avec un AIService factice
```

## Exécuter les tests

Nécessite Xcode / le toolchain Swift (non disponible dans l'environnement où ce projet a été
généré — voir la note dans le README racine du dépôt).

```bash
cd AINotesKit
swift test
```

Aucun test ne touche le réseau réel : les appels HTTP sont interceptés via `StubURLProtocol`
(un `URLProtocol` custom), et les use cases sont testés avec un `AIService` factice
(`MockAIService`). C'est le pendant Swift des mocks utilisés côté backend Python.

## Utilisation depuis l'app

```swift
import AINotesKit

let container = AppContainer(baseURL: URL(string: "http://localhost:8000")!)
let notes = try await container.noteRepository.fetchAll()
```

Voir `../AINotesApp/README.md` pour l'intégration dans une cible d'application SwiftUI.
