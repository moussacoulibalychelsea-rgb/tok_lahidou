Configuration Firebase — tok_lahidou

1) Créer un projet Firebase
- Va sur https://console.firebase.google.com/ et crée un projet.
- Ajoute une application Android et/ou iOS (et Web si besoin).

2) Fichiers de configuration
- Android: télécharge `google-services.json` et place-le dans `android/app/`.
- iOS: télécharge `GoogleService-Info.plist` et place-le dans `ios/Runner/`.
- Web: copie-colle la configuration Firebase dans `web/index.html` ou utilise `firebase.initializeApp(...)`.

3) Règles (exemples)
- Exemple règles Firestore: `firebase_rules/firestore.rules`.
- Exemple règles Storage: `firebase_rules/storage.rules`.
- Ces règles sont des points de départ — ajuste-les avant production.

4) Permissions
- Android: les permissions `INTERNET`, `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE` (maxSdkVersion 28) et `CAMERA` ont été ajoutées dans `android/app/src/main/AndroidManifest.xml`.
- iOS: `NSCameraUsageDescription` et `NSPhotoLibraryUsageDescription` ont été ajoutés dans `ios/Runner/Info.plist`.

5) Installer dépendances et lancer
```bash
flutter pub get
flutter run
```

6) Remarques
- Si tu veux que j'ajoute automatiquement `google-services.json` ou configure Firebase CLI pour toi, fournis les fichiers ou donne l'accès.
- Avant toute mise en production, revoie les règles de sécurité et active la facturation si tu utilises certaines API.
