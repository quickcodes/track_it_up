<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>track_it_up - README</title>
  <style>
    body {
      font-family: monospace;
      line-height: 1.6;
    }
  </style>
</head>
<body>

  <h1>📱 track_it_up</h1>
  <h2>Passive Activity Tracker built with 🧹 Clean Architecture, 🌀 BLoC, and ⚡ ObjectBox</h2>

  <p>
    <strong>track_it_up</strong> is a Flutter-based passive activity logger that helps repurpose old Android phones into private, offline activity trackers.
    It silently records:
    <ul>
      <li>📍 Most visited places</li>
      <li>🔋 Battery level changes</li>
      <li>📶 Network connectivity switches</li>
    </ul>
    Everything is stored locally and sorted by date for easy daily summaries — a minimal, privacy-first alternative to apps like <strong>Google Timeline</strong> or <strong>Life360</strong>, but running fully offline.
  </p>

  <hr>

  <h2>🌟 Why This Project?</h2>
  <ul>
    <li>⚙️ Designed with Clean Architecture — a great learning resource for Flutter beginners and pros alike.</li>
    <li>📦 Uses <strong>ObjectBox</strong> — a super-fast, zero-config local NoSQL database.</li>
    <li>🧠 Built on <strong>BLoC</strong> for predictable state management.</li>
    <li>🚀 Deployed with <strong>Shorebird</strong> — enabling faster updates to native Flutter apps without full app store redeploys.</li>
    <li>💡 A practical side project to understand local data handling, background services, architecture layers, and performance tuning on Android.</li>
  </ul>

  <hr>

  <h2>🔧 Core Components & Benefits</h2>
  <ul>
    <li><strong>🧹 Clean Architecture:</strong> Layered separation of concerns (data → domain → presentation), scalable and testable.</li>
    <li><strong>🌀 BLoC:</strong> Lightweight state management to handle UI logic reactively.</li>
    <li><strong>📦 ObjectBox:</strong> High-performance embedded database, perfect for local-only apps.</li>
    <li><strong>🌊 Shorebird:</strong> Hotfixes and app delivery without needing full store updates. Ideal for continuous delivery.</li>
  </ul>

  <hr>

  <h2>📁 Project Structure</h2>

  <pre><code>lib/
│   dependency_injection.dart                          # App-wide DI setup 💡
│   main.dart                                          # Entry point 🚀
│   objectbox-model.json                               # ObjectBox schema definitions 🗃️
│   objectbox.g.dart                                   # ObjectBox generated bindings ⚙️
│
├───config/
│   └─── theme_data.dart                               # App theming 🌈
│
├───core/
│   │   usecase.dart                                   # Base use case abstraction 🧩
│   ├───errors/
│   │   ├─── failure.dart                              # Generic failure contract 🚨
│   │   └─── local_db_failures.dart                    # DB-specific failures 📛
│   └───services/
│       ├─── background_service.dart                   # Background tracking logic ⚙️
│       ├─── device_info_service.dart                  # Device info utilities 📱
│       └─── local_db_service.dart                     # ObjectBox DB helpers 📦
│
└───features/
    ├───other/                                         # Placeholder for future expansion 🔮
    └───tracking/
        ├───data/
        │   ├───datasource/
        │   │   └─── tracking_local_data_source.dart   # Local DB access layer 💾
        │   ├───models/
        │   │   ├─── battery_status_model.dart         # Battery data model 🔋
        │   │   └─── device_info_model.dart            # Device/network/location model 📡
        │   └───repositories/
        │       └─── tracking_repository_impl.dart     # Repo implementation 🧠
        ├───domain/
        │   ├───entities/
        │   │   ├─── battery_status.dart               # Entity definition 🔋
        │   │   ├─── device_info.dart                  # Entity definition 📱
        │   │   ├─── device_summary.dart               # Daily summary entity 📊
        │   │   └─── frequently_visited.dart           # Location frequency entity 📍
        │   ├───repositories/
        │   │   └─── tracking_repository.dart          # Contract for tracking logic 📝
        │   └───usercase/
        │       ├─── add_device_info_usecase.dart
        │       ├─── clear_all_device_info_usecase.dart
        │       ├─── delete_device_info_by_date_usecase.dart
        │       ├─── delete_device_info_usecase.dart
        │       ├─── get_all_device_info_usecase.dart
        │       ├─── get_device_info_by_date_usecase.dart
        │       └─── tracking_usecases_impl.dart       # All use cases implementation 🔧
        └───presentation/
            ├───bloc/
            │   ├─── tracking_bloc.dart
            │   ├─── tracking_event.dart
            │   └─── tracking_state.dart               # BLoC state management 🌀
            ├───screens/
            │   ├─── data_entry_view.dart
            │   ├─── device_path_map_flutter_map.dart
            │   ├─── device_summary_screen.dart
            │   └─── home_screen.dart                  # Main UI components 🖼️
            └───widgets/
                ├───data_entry_view/
                │   ├─── de_delete_dialog.dart
                │   ├─── de_entry_chip_list.dart
                │   └─── de_entry_summary.dart
                ├───device_summary_screen/
                │   ├─── ds_daily_summary_card.dart
                │   ├─── ds_frequently_visited_place_list.dart
                │   └─── ds_summary_chip.dart
                └───home_screen/
                    ├─── hs_date_button.dart
                    ├─── hs_live_data_card.dart
                    ├─── hs_loading_state.dart
                    └─── hs_no_data_state.dart
</code></pre>

  <hr>

  <h2>🚀 Getting Started</h2>

  <h3>1. Install Dependencies</h3>
  <pre><code>flutter pub get</code></pre>

  <h3>2. Generate ObjectBox Bindings</h3>
  <pre><code>dart run build_runner build</code></pre>

  <p><strong>Tip:</strong> To resolve conflicts:</p>
  <pre><code>dart run build_runner build --delete-conflicting-outputs</code></pre>

  <hr>

  <h2>✅ Features</h2>
  <ul>
    <li>🔋 Tracks battery level drops and changes</li>
    <li>📶 Records network switch events</li>
    <li>📍 Logs GPS locations for frequently visited places</li>
    <li>📅 Displays clean, sortable daily summaries</li>
    <li>📱 Great for older Android devices not running Android 10+</li>
    <li>📦 Offline-first: all data is stored locally</li>
  </ul>

  <hr>

  <h2>📚 Comparisons</h2>
  <ul>
    <li><strong>Google Timeline:</strong> Offers location history but requires Google Account + internet access</li>
    <li><strong>Life360:</strong> Focuses on family location sharing, requires constant connectivity</li>
    <li><strong>track_it_up:</strong> Local-only, privacy-first, open and customizable</li>
  </ul>

  <hr>

  <h2>💡 Perfect for Learners</h2>
  <p>This project is a great way for beginners to get hands-on experience with:</p>
  <ul>
    <li>🧱 Clean Architecture implementation</li>
    <li>🌀 BLoC pattern for state management</li>
    <li>📦 ObjectBox DB usage</li>
    <li>📲 Working with Android permissions and background services</li>
  </ul>

  <hr>

  <h2>🧪 Future Improvements</h2>
  <ul>
    <li>[ ] Support modern background task strategies (WorkManager / Foreground service)</li>
    <li>[ ] Daily data export (CSV or PDF)</li>
    <li>[ ] Interactive charts and heatmaps</li>
    <li>[ ] Data encryption for extra privacy 🔐</li>
  </ul>

  <hr>

  <h2>🤝 Contributions</h2>
  <p>Found this interesting? Contributions are welcome! Fork it, experiment, or improve — let’s build cool and useful things together. 💪</p>

  <hr>

  <h2>📃 License</h2>
  <p>This project is licensed under the MIT License 📜.</p>

</body>
</html>
