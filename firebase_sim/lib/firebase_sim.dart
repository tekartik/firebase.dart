/// Client of the Firebase simulator: [getFirebaseSim] connects to a
/// `firebaseSimServe` server (`firebase_sim_server.dart`) and gives a
/// `Firebase` whose apps forward their calls to it. Runs on the Dart VM, the
/// web and Flutter.
library;

export 'src/firebase_sim.dart'
    show
        FirebaseSim,
        getFirebaseSim,
        getFirebaseSimUrl,
        getFirebaseSimPort,
        getFirebaseSimLocalhostUri,
        firebaseSimDefaultPort,
        firebaseSimDefaultProjectId;
export 'src/firebase_sim_client.dart'
    show FirebaseAppSim, debugFirebaseSimClient;
export 'src/firebase_sim_io.dart' show getFirebaseSimIo;
export 'src/firebase_sim_web.dart' show getFirebaseSimWeb;
