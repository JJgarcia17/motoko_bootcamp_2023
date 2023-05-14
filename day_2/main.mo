import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
actor homeworkDary{

  public type Homework = {
    title : Text;
    description : Text;
    dueDate : Time.Time;
    completed : Bool;
  };

  let homeworkDiary = Buffer.Buffer<Homework>(10);

  public shared func addHomework(homework : Homework) : async Nat {
      let index = homeworkDiary.size();
      homeworkDiary.add(homework);
      return index;
  };

  public shared query func getHomework(id : Nat) : async Result.Result<Homework,Text> {
    let homeworkData : ?Homework = homeworkDiary.getOpt(id);
    switch(homeworkData) {
      case(null) { return #err("invalid id (" # Nat.toText(id) # ") task not found"); };
      case(?homeworkData) { return #ok(homeworkData); };
    };
  };

  public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(),Text> {
    let homeworkData : ?Homework = homeworkDiary.getOpt(id);
    switch(homeworkData) {
      case(null) { return #err("invalid id (" # Nat.toText(id) # ") task not found"); };
      case(?homeworkData) { 
          homeworkDiary.put(id,homework);
          return #ok();
       };
    };
  };

  public shared func markAsCompleted(id: Nat) : async Result.Result<(),Text> {
    let homeworkData : ?Homework = homeworkDiary.getOpt(id);
    switch(homeworkData) {
      case(null) { return #err("invalid id (" # Nat.toText(id) # ") task not found"); };
      case(?homeworkData) {
          var markCompleted : Homework = {
            title = homeworkData.title;
            description = homeworkData.description;
            dueDate = homeworkData.dueDate;
            completed = true;
          };
          
          homeworkDiary.put(id,markCompleted);

          return #ok();
       };
    };
  };

  public shared func deleteHomework(id : Nat) : async Result.Result<(),Text> {
    let homeworkData : ?Homework = homeworkDiary.getOpt(id);
    switch(homeworkData) {
      case(null) { return #err("invalid id (" # Nat.toText(id) # ") task not found");   };
      case(?homeworkData) {
          let deleteHomeWork = homeworkDiary.remove(id);
          return #ok();
       };
    };
  };

  public shared query func getAllHomework() : async [Homework] {
      return Buffer.toArray<Homework>(homeworkDiary);
  };

  public shared query func getPendingHomework() : async [Homework] {
      homeworkDiary.filterEntries(func(_,item) = item.completed == false );
      return Buffer.toArray<Homework>(homeworkDiary);
  };

  public shared query func searchHomework(searchTerm : Text) : async [Homework] {
      var search = Buffer.clone(homeworkDiary);
      search.filterEntries(func(_,item) = Text.contains(item.title, #text searchTerm) or Text.contains(item.description, #text searchTerm) );
      return Buffer.toArray<Homework>(search);
  };
}