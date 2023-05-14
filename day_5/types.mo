import Result "mo:base/Result";
import Text "mo:base/Text";
import Bool "mo:base/Bool";

module {

  public type StudentProfile = {
    name : Text;
    team : Text;
    graduate : Bool;
  };

  public type CalculatorInterface = actor {
    add : shared (n : Int) -> async Int;
    sub : shared (n : Int) -> async Int;
    reset : shared () -> async Int;
  };

  public type TestError = {
        #UnexpectedValue : Text;
        #UnexpectedError : Text;
  };
  public type TestResult = Result.Result<(), TestError>;

};