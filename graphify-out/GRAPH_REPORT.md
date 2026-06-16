# Graph Report - .  (2026-06-15)

## Corpus Check
- Corpus is ~13,954 words - fits in a single context window. You may not need a graph.

## Summary
- 519 nodes · 624 edges · 68 communities (37 shown, 31 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 12 edges (avg confidence: 0.81)
- Token cost: 2,532 input · 1,870 output

## Community Hubs (Navigation)
- [[_COMMUNITY_ProudMoments & Subscriptions|ProudMoments & Subscriptions]]
- [[_COMMUNITY_Habit Data Repository|Habit Data Repository]]
- [[_COMMUNITY_Biome Linter Config|Biome Linter Config]]
- [[_COMMUNITY_Habit Form UI|Habit Form UI]]
- [[_COMMUNITY_Next.js Site Package|Next.js Site Package]]
- [[_COMMUNITY_App Theme & Habit ViewModel|App Theme & Habit ViewModel]]
- [[_COMMUNITY_Monorepo Dev Tooling|Monorepo Dev Tooling]]
- [[_COMMUNITY_Biome Lint Rules|Biome Lint Rules]]
- [[_COMMUNITY_Proudly Plus Paywall|Proudly Plus Paywall]]
- [[_COMMUNITY_TypeScript Config|TypeScript Config]]
- [[_COMMUNITY_Habit Domain Model|Habit Domain Model]]
- [[_COMMUNITY_Local Dev Infrastructure|Local Dev Infrastructure]]
- [[_COMMUNITY_Turborepo Build Pipeline|Turborepo Build Pipeline]]
- [[_COMMUNITY_Habit Detail View|Habit Detail View]]
- [[_COMMUNITY_Habits List View|Habits List View]]
- [[_COMMUNITY_Insights & Glass UI|Insights & Glass UI]]
- [[_COMMUNITY_Today Dashboard|Today Dashboard]]
- [[_COMMUNITY_SwiftData Habit Model|SwiftData Habit Model]]
- [[_COMMUNITY_Floating Action Button|Floating Action Button]]
- [[_COMMUNITY_Insights Analytics|Insights Analytics]]
- [[_COMMUNITY_iOS Package Config|iOS Package Config]]
- [[_COMMUNITY_App Entry & Model Container|App Entry & Model Container]]
- [[_COMMUNITY_Profile View|Profile View]]
- [[_COMMUNITY_Proud Moments View|Proud Moments View]]
- [[_COMMUNITY_Theme ViewModel|Theme ViewModel]]
- [[_COMMUNITY_Habit Completion Model|Habit Completion Model]]
- [[_COMMUNITY_Glass Card Component|Glass Card Component]]
- [[_COMMUNITY_Haptics Utilities|Haptics Utilities]]
- [[_COMMUNITY_Root Content View|Root Content View]]
- [[_COMMUNITY_App Layout & Fonts|App Layout & Fonts]]
- [[_COMMUNITY_Onboarding Flow|Onboarding Flow]]
- [[_COMMUNITY_Theme Picker View|Theme Picker View]]
- [[_COMMUNITY_Legacy Item Model|Legacy Item Model]]
- [[_COMMUNITY_Dev Shell Script|Dev Shell Script]]
- [[_COMMUNITY_Feature Flags Config|Feature Flags Config]]
- [[_COMMUNITY_System Appearance|System Appearance]]
- [[_COMMUNITY_Devbox Environment|Devbox Environment]]
- [[_COMMUNITY_Window Icon Asset|Window Icon Asset]]
- [[_COMMUNITY_TLS Cert Generation|TLS Cert Generation]]
- [[_COMMUNITY_Secret Decryption Script|Secret Decryption Script]]
- [[_COMMUNITY_Secret Encryption Script|Secret Encryption Script]]
- [[_COMMUNITY_Secret Sync Script|Secret Sync Script]]
- [[_COMMUNITY_Profile ViewModel|Profile ViewModel]]
- [[_COMMUNITY_File Icon Asset|File Icon Asset]]
- [[_COMMUNITY_RevenueCat Config|RevenueCat Config]]
- [[_COMMUNITY_Bun Add Script|Bun Add Script]]
- [[_COMMUNITY_Bun Dev Add Script|Bun Dev Add Script]]
- [[_COMMUNITY_Bun Remove Script|Bun Remove Script]]
- [[_COMMUNITY_Key Generation Script|Key Generation Script]]
- [[_COMMUNITY_Local Init Script|Local Init Script]]
- [[_COMMUNITY_Hosts Remove Script|Hosts Remove Script]]
- [[_COMMUNITY_Local Reset Script|Local Reset Script]]
- [[_COMMUNITY_Hosts Sync Script|Hosts Sync Script]]
- [[_COMMUNITY_UI Add Script|UI Add Script]]
- [[_COMMUNITY_Next.js Config|Next.js Config]]
- [[_COMMUNITY_PostCSS Config|PostCSS Config]]
- [[_COMMUNITY_Today ViewModel|Today ViewModel]]
- [[_COMMUNITY_Globe Icon Design|Globe Icon Design]]
- [[_COMMUNITY_Site Static Assets|Site Static Assets]]
- [[_COMMUNITY_Globe Icon SVG|Globe Icon SVG]]
- [[_COMMUNITY_Next.js Logo|Next.js Logo]]
- [[_COMMUNITY_Next.js Brand|Next.js Brand]]
- [[_COMMUNITY_Vercel Logo|Vercel Logo]]
- [[_COMMUNITY_Vercel Site Assets|Vercel Site Assets]]
- [[_COMMUNITY_Vercel Triangle Symbol|Vercel Triangle Symbol]]

## God Nodes (most connected - your core abstractions)
1. `View` - 29 edges
2. `HabitRepository` - 24 edges
3. `SubscriptionStore` - 19 edges
4. `compilerOptions` - 16 edges
5. `HabitFormView` - 14 edges
6. `ProudlyAppTheme` - 14 edges
7. `Habit` - 10 edges
8. `SubscriptionPackageButton` - 10 edges
9. `HabitDetailView` - 9 edges
10. `DateFormatter` - 8 edges

## Surprising Connections (you probably didn't know these)
- `Proudly Project` --references--> `Process Compose Orchestration`  [INFERRED]
  README.md → process-compose.yaml
- `Proudly Project` --references--> `Proudly Next.js Site`  [INFERRED]
  README.md → apps/site/README.md
- `Proudly Project` --references--> `SOPS Secrets Encryption Config`  [INFERRED]
  README.md → .sops.yaml
- `Site Process (process-compose)` --references--> `Proudly Next.js Site`  [INFERRED]
  process-compose.yaml → apps/site/README.md
- `RootView` --references--> `View`  [EXTRACTED]
  apps/ios/Proudly/ProudlyApp.swift → apps/ios/Proudly/Shared/Design/GlassModifier.swift

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Traefik TLS Secure Routing Stack** — traefik_traefik_yaml_traefik_main_config, traefik_config_yaml_traefik_dynamic_config, traefik_config_yaml_tls_options, traefik_config_yaml_tls_certs, traefik_traefik_yaml_root_ca [INFERRED 0.85]
- **Local Development Infrastructure Stack (process-compose, Traefik, Site)** — process_compose_yaml_process_compose, process_compose_yaml_traefik_process, process_compose_yaml_site_process, traefik_traefik_yaml_traefik_main_config, site_readme_nextjs_site [EXTRACTED 0.95]

## Communities (68 total, 31 thin omitted)

### Community 0 - "ProudMoments & Subscriptions"
Cohesion: 0.11
Nodes (18): Color, Date, Int, String, Bool, Package, String, Void (+10 more)

### Community 1 - "Habit Data Repository"
Cohesion: 0.17
Nodes (12): Bool, Date, Habit, Int, PersistentHabit, ProudMoment, Set, String (+4 more)

### Community 2 - "Biome Linter Config"
Cohesion: 0.07
Nodes (28): recommended, source, assist, actions, enabled, css, parser, files (+20 more)

### Community 3 - "Habit Form UI"
Cohesion: 0.13
Nodes (15): Bool, CGFloat, Color, Date, Habit, Int, String, Void (+7 more)

### Community 4 - "Next.js Site Package"
Cohesion: 0.08
Nodes (25): dependencies, next, react, react-dom, devDependencies, babel-plugin-react-compiler, tailwindcss, @tailwindcss/postcss (+17 more)

### Community 5 - "App Theme & Habit ViewModel"
Cohesion: 0.09
Nodes (20): Habit, Bool, Color, Double, CaseIterable, ProudlyAppTheme, lavenderDream, liquidGlass (+12 more)

### Community 6 - "Monorepo Dev Tooling"
Cohesion: 0.09
Nodes (21): devDependencies, @biomejs/biome, tailwindcss, turbo, @types/bun, @typescript/native-preview, name, packageManager (+13 more)

### Community 7 - "Biome Lint Rules"
Cohesion: 0.10
Nodes (21): noStaticOnlyClass, noUselessFragments, useExhaustiveDependencies, useParseIntRadix, useUniqueElementIds, next, react, linter (+13 more)

### Community 8 - "Proudly Plus Paywall"
Cohesion: 0.15
Nodes (16): Bool, Color, Package, String, Void, BenefitCard, ProudlyPlusBenefit, ProudlyPlusView (+8 more)

### Community 9 - "TypeScript Config"
Cohesion: 0.10
Nodes (19): compilerOptions, allowJs, esModuleInterop, incremental, isolatedModules, jsx, lib, module (+11 more)

### Community 10 - "Habit Domain Model"
Cohesion: 0.12
Nodes (16): Bool, Color, Int, Set, String, UUID, Habit, Int (+8 more)

### Community 11 - "Local Dev Infrastructure"
Cohesion: 0.15
Nodes (17): Process Compose Orchestration, Site Process (process-compose), Traefik Process (process-compose), Proudly Project, Proudly Next.js Site, AGE Encryption Key (dev), SOPS Path Rule: tools/secrets/*.local.yaml, SOPS Secrets Encryption Config (+9 more)

### Community 12 - "Turborepo Build Pipeline"
Cohesion: 0.12
Nodes (16): dependsOn, inputs, outputs, cache, cache, persistent, cache, dependsOn (+8 more)

### Community 13 - "Habit Detail View"
Cohesion: 0.25
Nodes (7): Bool, Color, Habit, String, Void, HabitDetailView, StatCard

### Community 14 - "Habits List View"
Cohesion: 0.22
Nodes (9): Bool, CGFloat, Color, Double, Habit, String, HabitCardView, HabitIconView (+1 more)

### Community 15 - "Insights & Glass UI"
Cohesion: 0.25
Nodes (6): Color, String, CGFloat, View, InsightStatCard, InsightsView

### Community 16 - "Today Dashboard"
Cohesion: 0.25
Nodes (7): Bool, Double, Habit, Int, Void, HabitRowView, TodayView

### Community 17 - "SwiftData Habit Model"
Cohesion: 0.36
Nodes (7): Bool, Date, Int, String, UUID, PersistentHabit, PersistentHabitCompletion

### Community 18 - "Floating Action Button"
Cohesion: 0.22
Nodes (7): Color, String, Void, ButtonStyle, Configuration, FloatingActionButton, FloatingActionButtonStyle

### Community 19 - "Insights Analytics"
Cohesion: 0.36
Nodes (6): Habit, Int, String, DayData, DayData, InsightsViewModel

### Community 20 - "iOS Package Config"
Cohesion: 0.25
Nodes (7): name, private, scripts, format, lint, pre:push, version

### Community 21 - "App Entry & Model Container"
Cohesion: 0.33
Nodes (5): App, ModelContainer, ProudlyApp, RootView, Scene

### Community 22 - "Profile View"
Cohesion: 0.33
Nodes (6): Color, String, PlusBadge, ProfileRow, ProfileView, Trailing

### Community 23 - "Proud Moments View"
Cohesion: 0.38
Nodes (5): Date, ProudMoment, String, ProudMomentCard, ProudMomentsView

### Community 24 - "Theme ViewModel"
Cohesion: 0.52
Nodes (3): Bool, ProudlyAppTheme, ThemeViewModel

### Community 25 - "Habit Completion Model"
Cohesion: 0.43
Nodes (5): Date, PersistentHabit, String, UUID, PersistentHabitCompletion

### Community 26 - "Glass Card Component"
Cohesion: 0.43
Nodes (5): CGFloat, Color, Content, ThemedGlassCard, ThemeViewModel

### Community 27 - "Haptics Utilities"
Cohesion: 0.29
Nodes (3): UIImpactFeedbackGenerator, UINotificationFeedbackGenerator, Haptics

### Community 28 - "Root Content View"
Cohesion: 0.40
Nodes (3): IndexSet, Item, ContentView

### Community 29 - "App Layout & Fonts"
Cohesion: 0.40
Nodes (3): geistMono, geistSans, metadata

### Community 30 - "Onboarding Flow"
Cohesion: 0.40
Nodes (4): Color, String, Void, OnboardingView

### Community 31 - "Theme Picker View"
Cohesion: 0.40
Nodes (3): ProudlyAppTheme, Void, ThemeView

### Community 33 - "Dev Shell Script"
Cohesion: 0.83
Nodes (3): display_logs(), usage(), dev.sh script

### Community 37 - "Window Icon Asset"
Cohesion: 1.00
Nodes (3): Browser Window / App Window Icon, Window SVG Icon, Traffic Light Dots (Window Control Circles)

## Knowledge Gaps
- **220 isolated node(s):** `IndexSet`, `UUID`, `Color`, `Int`, `Set` (+215 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **31 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `View` connect `Insights & Glass UI` to `Habit Form UI`, `Proudly Plus Paywall`, `Habit Domain Model`, `Habit Detail View`, `Habits List View`, `Today Dashboard`, `Floating Action Button`, `App Entry & Model Container`, `Profile View`, `Proud Moments View`, `Glass Card Component`, `Root Content View`, `Onboarding Flow`, `Theme Picker View`?**
  _High betweenness centrality (0.139) - this node is a cross-community bridge._
- **Why does `DateFormatter` connect `Habit Data Repository` to `Insights Analytics`, `Habit Form UI`, `Habit Detail View`, `Proud Moments View`?**
  _High betweenness centrality (0.054) - this node is a cross-community bridge._
- **Why does `ProudlyPlusBenefit` connect `Proudly Plus Paywall` to `ProudMoments & Subscriptions`?**
  _High betweenness centrality (0.050) - this node is a cross-community bridge._
- **What connects `IndexSet`, `UUID`, `Color` to the rest of the system?**
  _220 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `ProudMoments & Subscriptions` be split into smaller, more focused modules?**
  _Cohesion score 0.10804597701149425 - nodes in this community are weakly interconnected._
- **Should `Biome Linter Config` be split into smaller, more focused modules?**
  _Cohesion score 0.07389162561576355 - nodes in this community are weakly interconnected._
- **Should `Habit Form UI` be split into smaller, more focused modules?**
  _Cohesion score 0.12535612535612536 - nodes in this community are weakly interconnected._