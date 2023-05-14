import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Types "types";
import Result "mo:base/Result";
import Bool "mo:base/Bool";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Error "mo:base/Error";
import Ic "ic";

actor verifer{

  //PART 1

  //Part 1 var Begin
  type studentProfile = Types.StudentProfile;
  var studentProfileStore = HashMap.HashMap<Principal,studentProfile>(0, Principal.equal, Principal.hash);
  stable var studentProfileData : [(Principal,studentProfile)]  = [];
  //End

  //Part 2 var Begin
  type calculatorInterface = Types.CalculatorInterface;
  public type resultTest = Types.TestResult;
  public type resultTestError = Types.TestError;
  //End


  private func validateIsRegistered(profile : Principal) : Bool {
    var searchProfile : ?studentProfile = studentProfileStore.get(profile);

    switch(searchProfile) {
      case(null) { return false;};
      case(searchProfile) { return true;};
    };

  };

  public shared ({caller}) func addMyProfile( profile : studentProfile) : async Result.Result<(), Text> {
    if(Principal.isAnonymous(caller)) { return #err("You are not logged in");};
    if(validateIsRegistered(caller)) {return #err("You are not registered as a student");};

    studentProfileStore.put(caller,profile);
    return #ok();
  };

  public shared query ({caller}) func seeAProfile(profile : Principal) : async Result.Result<(studentProfile),Text> {
    var stundent : ?studentProfile = studentProfileStore.get(profile);

    switch(stundent) {
      case(null) { return #err("You are not registered as a student"); };
      case(?stundent) {return #ok(stundent); };
    };
  };

  public shared ({caller}) func updateMyProfile(profile : studentProfile) : async Result.Result<(),Text> {
    if(Principal.isAnonymous(caller)) { return #err("You must be logged in to edit your student profile");};
    if(validateIsRegistered(caller)) { return #err("You do not have a student profile to edit");};

    ignore studentProfileStore.replace(caller,profile);
    return #ok();
  };

  public shared ({caller}) func deleteMyProfile() : async Result.Result<(),Text> {
    if(Principal.isAnonymous(caller)){ return #err("You must log in to delete your profile")};
    if(validateIsRegistered(caller)){ return #err("You do not have a profile to delete")};

    studentProfileStore.delete(caller);
    return #ok();
  };

  system func preupgrade() {
    studentProfileData := Iter.toArray(studentProfileStore.entries());
  };
  
  system func postupgrade() {
    for((principal,stundent) in studentProfileData.vals())
    {
      studentProfileStore.put(principal,stundent);
    };
    studentProfileData := [];
  };
  //END

  //PART 2
  public func test(canisterId : Principal) : async resultTest {

    try {
      let interfaceCalculator = actor(Principal.toText(canisterId)) : actor {
      add : shared (x : Nat) -> async Int;
      sub : shared (x : Nat) -> async Int;
      reset : shared () -> async Int;
      };

      let testReset : Int = await interfaceCalculator.reset();
      if (testReset != 0) { return #err(#UnexpectedValue("After a reset, counter should be 0!")); };

      let testAdd : Int = await interfaceCalculator.add(2);
      if (testAdd != 2) { return #err(#UnexpectedValue("After 0 + 2, counter should be 2!")); };

      let testSub : Int = await interfaceCalculator.sub(2);
      if (testSub != 0) { return #err(#UnexpectedValue("After 2 - 2, counter should be 0!")); };

      return #ok();
    }catch (e) {
      return #err(#UnexpectedError(Error.message(e)));
    }
  };
  //END

  //PART 3
  public func verifyOwnership(canisterId : Principal, principalId : Principal) : async Bool {
    let managementCanister : Ic.ManagementCanisterInterface = actor ("aaaaa-aa");
    try{
      let resultCanister = await managementCanister.canister_status({ canister_id = canisterId});
      let controllers = resultCanister.settings.controllers;
      for(principal in controllers.vals())
      {
        if(principal == principalId){ return true; }; 
      };
      return false;
    }catch (e)
    {
        let controllers = Ic.parseControllersFromCanisterStatusErrorIfCallerNotController(Error.message(e));
        for(principal in controllers.vals())
        {
          if(principal == principalId) { return true;};
        };
        return false;
    }
  };
  //END

  //PART 4
  public shared ({ caller }) func verifyWork(canisterId : Principal, principalId : Principal) : async Result.Result<(), Text> {
    let isOwner = await verifyOwnership(canisterId,principalId);
    if(not (isOwner)) { return #err("You are not the owner of the canister you are trying to call");};

    let resulTest = await test(canisterId);
    switch(resulTest) {
      case (#err(_)) { return #err("canister tests have not been passed"); };
      case (#ok()){
        var stundent : ?studentProfile = studentProfileStore.get(principalId);
        switch(stundent) {
          case(null) { return #err("Profile not Found");};
          case(?stundent) {
            let updateProfile = {
              name = stundent.name;
              team = stundent.team;
              graduate = true; 
            };
            studentProfileStore.put(principalId,updateProfile);
            return #ok();
           };
        };
      }
    };

    return #err("not implemented");
  };
  //END
}