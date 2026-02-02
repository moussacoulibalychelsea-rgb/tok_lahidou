# tok_lahidou

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

Marketplace sociale locale pour commerçants maliens.

Cahier de charge — Lahidou Tok
1. Contexte & objectifs
    • But : Plateforme mobile/social pour commerçants et clients maliens, discovery par scroll infini, likes, abonnements, badges, notes, DoniCoins, commission 10% (8% pour premium).
    • Public cible : Commerçants locaux, clients urbains & périurbains, utilisateurs mobile-money.
    • Priorité : Lancer vite un MVP qui prouve l’usage et génère les premières ventes.

2. Livrables (MVP)
    1. Application mobile (Android + PWA) — écran principal : feed scroll infini de produits.
    2. Authentification (téléphone + mot de passe, ou OTP mobile).
    3. Espace vendeur : ajouter/modifier produit (titre, description, prix, 1–3 images, localisation).
    4. Espace client : like, follow vendeur, enregistrer produit, acheter.
    5. Paiements : intégration Mobile Money (au minimum, voir section paiement), et wallet DoniCoins interne.
    6. Système de commission 10% (8% si vendeur premium).
    7. Badges/points basiques : gains de DoniCoins pour actions clefs (publier, like, scrolls limités).
    8. Profil utilisateur, notes & avis, tableau de bord vendeur (ventes, solde DoniCoins).
    9. Admin web simple : gestion utilisateurs, contrôle contenus, validation vendeurs, stats de base.
    10. Mécanique de conversion DoniCoins → FCFA (processus KYC pour retraits).
    11. Modération & signalement produits.

3. Fonctionnalités détaillées (MVP → v1)
Feed principal (scroll infini)
    • Chargement page par page (pagination), algorithme basique : fraîcheur + likes + proximité géographique.
    • Fallback si pas d’internet (cache léger).
Publication produit
    • 1–3 images, compression côté client, catégories, tag localité, stock (optionnel).
Wallet & DoniCoins
    • Gains : publication (ex : 50 DoniCoins), premier like d’un produit, referral.
    • Utilisations : booster produit, acheter coupons, paiement partiel.
    • Conversion : retrait soumis à KYC, admin valide.
Paiement / Commission
    • Calcul automatique 10% sur vente ; 8% pour comptes premium.
    • Débit du compte vendeur après confirmation livraison (ou confirmation manuelle au début).
Vérification & sécurité
    • Vérif. téléphone, upload ID pour vendeurs.
    • Signalement / blocage / médiation.

4. Non-fonctionnel
    • Performance : temps de chargement < 3s sur 4G.
    • Disponibilité : initialement 99% ; évoluer selon usage.
    • Sécurité : chiffrement des tokens, stocker images sur object storage, logs d’audit.
    • Scalabilité : architecture basée sur services managés (évolutifs).

5. Architecture recommandée (MVP -> scale)
    • Frontend : Flutter (Android + iOS + PWA possible) — un seul codebase.
    • Backend : Firebase (Auth, Firestore, Storage, Cloud Functions) ou Node.js + PostgreSQL (Supabase) si tu préfères open-source.
    • Stockage images : Firebase Storage / S3-compatible (Supabase Storage).
    • Notifications : FCM (Firebase Cloud Messaging).
    • Admin : simple dashboard web (React / Next.js ou panel Supabase).
    • Paiements Mobile Money : intégration via API opérateurs (Orange Money, Moov…) ou via agrégateur local.
    • Hébergement : backend serverless (Cloud Functions) ou VPS (DigitalOcean, Scaleway).

6. Modèle de données (extrait)
    • Users: id, name, phone, role (client/vendeur/admin), badges[], wallet{donicoins,fcfa}, verified
    • Products: id, sellerId, title, desc, priceFCFA, images[], category, location, likesCount, createdAt
    • Orders: id, productId, buyerId, sellerId, price, commission, status
    • Badges/Achievements: id, userId, type, awardedAt
    • Transactions: id, userId, type(credit/debit), amount, balanceAfter, meta

7. Plan de développement & tâches (ordre conseillé)
Phase 0 — préparation (1 semaine)
    • Spécs minimales, wireframes écran principal, choix tech stack.
Phase 1 — MVP essentiel (4–8 semaines solo, raisonnable)
    • Auth + profils
    • Feed scroll infini (publication + affichage)
    • Upload images + compression client
    • Like/Follow + notes
    • Wallet DoniCoins basique
    • Admin minimal
    • Test end-to-end
Phase 2 — paiements & production (2–4 semaines)
    • Intégration Mobile Money (ou solution manuelle au début)
    • Commission & règles premium
    • KYC basique & retrait DoniCoins
    • Déploiement production (hébergement et domaine)
Phase 3 — croissance & ops
    • Algorithme de recommandation amélioré
    • Campagnes acquisition
    • Monitoring & scalabilité
Ces durées sont indicatives pour une personne motivée qui code ~6–8h/jour.

8. Faisabilité sur une seule machine (Core i5 | 8 GB RAM)
    • Développement : totalement possible. Flutter + Firebase dev local OK. Tu peux exécuter émulateur Android (plus confortable si tu utilises un téléphone réel pour tester). 8 GB demande d’être prudent (éviter plusieurs émulateurs lourds en même temps).
    • Build & tests : possible mais builds iOS nécessitent macOS (si tu veux iOS natif). Pour Android et PWA, ton PC suffit.
    • Production : ne PAS héberger la production sur ta machine personnelle (connexion, disponibilité, sécurité). Utiliser services managés (hébergement cloud) est essentiel.

9. Stockage des données — options & coûts
Estimations de stockage (exemples pratiques)
    • Image moyenne optimisée ≈ 500 KB (après compression).
    • 3 images / produit → 500 KB * 3 = 1500 KB par produit ≈ 1.46 MB.
    • Pour 1 000 produits → ~1 500 000 KB ≈ 1.43 GB.
    • Pour 10 000 produits → ~15 000 000 KB ≈ 14.31 GB.
(Détails : calculs en base 1024, arrondis ; images = le poste le plus coûteux en stockage.)
Bases de données métadonnées
    • Chaque produit, utilisateur, transaction : quelques centaines d’octets.
    • Pour 10k produits + 10k users → base metadata < 50–200 MB initialement.
Recommandation
    • Début : Firebase Storage / Firebase Firestore (Free tier généreux). Ou Supabase (free) + object storage.
    • Scale : S3 (ou Scaleway Object Storage) + PostgreSQL.

10. Coûts estimatifs (approximations)
J’indique 3 scénarios : Zéro budget (bootstrap), Petite dépense mensuelle, Investissement sérieux.
A) Zéro / très faible budget (bootstrap)
    • Utilise free tiers : Firebase (Spark), Supabase free, Vercel/Netlify (PWA), domaine gratuit possible via subdomain.
    • Coût initial : 0–20 USD (domäne cheap / badges design DIY).
    • Limites : quotas (requests, storage), paiement Mobile Money difficile sans compte pro.
B) Petit budget (réaliste)
    • Hébergement & services (après dépassement free tier) : 20–150 USD / mois.
    • Domaine + SSL : 10–20 USD / an.
    • Intégration Mobile Money / agrégateur : peut demander frais d’ouverture de compte, ou commission.
    • Total initial (dev solo) : 0–500 USD si tu fais tout toi-même.
    • Total mensuel : 20–200 USD selon usage.
C) Production professionnelle (scale)
    • Développement pro (freelance ou équipe) : 500–5000 USD (selon qualité et design).
    • Intégration opérateurs, conformité, KYC, tests, marketing : 1 000–10 000+ USD.
    • Hébergement + stockage + backups + monitoring : 100–1000 USD / mois.
    • Conclusion : pour “bien faire”, prévoir quelques milliers d’euros au départ, puis 100–1 000 USD/mois selon montée en charge.
Remarque : ces fourchettes sont des estimations générales — les coûts réels (notamment intégration Mobile Money) varient selon négociations locales.

11. Scénarios sans budget / comment maximiser en mode gratuit
    • MVP lean : limiter fonctionnalités (1 image / produit, pas de retrait DoniCoins automatique, paiement manuel via mobile money lien / QR).
    • Utiliser PWA plutôt qu’application native iOS (évite Mac + App Store initial).
    • Utiliser Firebase / Supabase free tier : hébergement, auth, storage gratuit jusqu’à un certain seuil.
    • Paiements manuels : au début, demander au client de payer via mobile-money manuellement et le vendeur confirme; l’app enregistre la commande — tu règles la commission manuellement ; ça permet de valider le produit sans intégration API coûteuse.
    • Contrib. en nature : demander à designers / marketeurs débutants de collaborer pour parts/commissions.
    • Incubateurs & concours : candidater à programmes locaux (aide, subventions).
    • Monétiser tôt : prévoir options payantes (boosts payants) pour générer revenu et payer hébergement.

12. Risques & points à surveiller
    • Fraude / faux vendeurs → exiger KYC progressif.
    • Litiges paiement/livraison → processus de médiation.
    • Capacité mobile-money : négocier avec opérateurs locaux (Orange, Moov).
    • Légalité/Comptabilité : conformité fiscale locale pour commissions perçues.

13. Mesures d’urgence si tu commences seul
    • Lancer PWA + Android (via Flutter).
    • Déployer backend sur Firebase free tier.
    • Gérer paiements manuellement au début pour valider le marché.
    • Automatiser ensuite (intégration Mobile Money, conversion DoniCoins, retraits).
    • Itérer vite, mesurer, puis investir.

14. Acceptation / critères de réussite MVP
    • 100 utilisateurs actifs mensuels, 10 ventes réalisées, fiabilité commande > 90%, système de badges opérationnel.
    • Commission 10% automatiquement calculée dans commandes.
    • DoniCoins crédités pour actions clés.
