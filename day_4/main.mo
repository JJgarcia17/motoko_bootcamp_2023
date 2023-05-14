import TrieMap "mo:base/TrieMap";

import Account "account";
import Nat "mo:base/Nat";
import Order "mo:base/Order";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Iter "mo:base/Iter";

import RemoteCanisterIc "remoteCanisterIc";
import Principal "mo:base/Principal";
import Array "mo:base/Array";

actor motocoin {

  public type accountWallet = Account.Account;

  stable var infoCoin = {
    name : Text = "MotoCoin";
    symbol : Text = "MOC";
    var supply : Nat = 0;
  };

  let ledger = TrieMap.TrieMap<accountWallet, Nat>(Account.accountsEqual,Account.accountsHash);

  public shared query func name() : async Text {
    return infoCoin.name;
  };

  public shared query func symbol() : async Text {
    return infoCoin.symbol;
  };

  public shared query func totalSupply() : async Nat {
    return infoCoin.supply;
  };

  public shared query func balanceOf(account : accountWallet) : async Nat {
    let balanceAccount : ?Nat = ledger.get(account);
    switch(balanceAccount) {
      case(null) { return 0 };
      case(?balanceAccount) { return balanceAccount };
    };
  };

  public shared ({caller}) func transfer (from : accountWallet , to : accountWallet , amount : Nat) : async Result.Result<(),Text> {
    try{
      let  fromAccount : ?Nat = ledger.get(from);
      switch(fromAccount){
        case(null){ return #err("has no funds") };
        case(?fromAccount) {
          if(fromAccount < amount) { return #err("do not have enough funds in " # infoCoin.name # "")};
          ignore ledger.replace(from,fromAccount - amount);
          let toAccount : ?Nat = ledger.get(to);
          switch(toAccount) {
            case(null) { ledger.put(to, amount ); return #ok() };
            case(?toAccount) { ignore ledger.replace(to, toAccount + amount); return #ok() };
          };
        }
      };
    }catch (e) {
      return  #err("an error has occurred in the transaction");
    }
  };

  private func addBalanceWallet(wallet : accountWallet, amount : Nat) : async () {
    let stundentwallet : ?Nat = ledger.get(wallet);

    switch (stundentwallet) {
      case(null) {  ledger.put(wallet, amount); return (); };
      case(?studenWallet) { ignore ledger.replace(wallet, studenWallet + amount); return (); };
    }
  };

  public func airdrop() : async Result.Result<(), Text> {
    try{
      var studentsArray  : [Principal] = await RemoteCanisterIc.RemoteActor.getAllStudentsPrincipal();
      // let studentsArray  : [Principal] = await RemoteCanisterIc.RemotoActorLocal.getAllStudentsPrincipal();
      for (student in studentsArray.vals()) {
        var studentWallet = {owner = student; subaccount = null};
        await addBalanceWallet(studentWallet, 100);
        infoCoin.supply += 100;
      };

      return #ok();
    }catch (e){
      return #err("error when repeating airdrop");
    };
  };




}