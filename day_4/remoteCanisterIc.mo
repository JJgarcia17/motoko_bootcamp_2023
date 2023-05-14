import Principal "mo:base/Principal";
import RemotoCanisterLocal "remotoCanisterLocal";


module {
  // for IC deployment
  public let RemoteActor = actor("rww3b-zqaaa-aaaam-abioa-cai") : actor {
    getAllStudentsPrincipal : shared () -> async [Principal];
  };

  public let RemotoActorLocal = actor("cbopz-duaaa-aaaaa-qaaka-cai") : actor {
        getAllStudentsPrincipal : shared () -> async [Principal];
  };

}