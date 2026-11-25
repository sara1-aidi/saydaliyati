/// Where the FastAPI server is running.
///
///  • Android emulator ........ http://10.0.2.2:8000
///  • Real phone (same Wi-Fi) . http://<IP of your PC>:8000   (e.g. 192.168.1.4)
///  • Windows desktop / Chrome  http://localhost:8000
const String kApiBaseUrl = 'http://localhost:8000';

/// true  = use the in-memory sample data (no server needed, e.g. for a quick demo)
/// false = talk to the real REST API
const bool kUseMockData = false;
