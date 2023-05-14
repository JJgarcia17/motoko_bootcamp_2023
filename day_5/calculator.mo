import Int "mo:base/Int";

actor class Calculator() {
  var counter : Int = 0;

  public shared func add(n : Int) : async Int {
    counter := counter + n;
    return counter;
  };

  public shared func sub(n : Nat) : async Int {
    counter := counter - n;
    return counter;
  };

  public shared func reset() : async Int {
    counter := 0;
    return counter;
  };

};