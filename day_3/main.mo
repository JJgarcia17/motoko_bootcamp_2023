import Order "mo:base/Order";
import Hash "mo:base/Hash";
import HashMap "mo:base/HashMap";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";

actor studentWall{
  
    public type Content = {
        #Text: Text;
        #Image: Blob;
        #Video: Blob;
    };

    public type Message = {
        vote: Nat;
        content : Content;
        creator: Principal;
    };

    type Order = Order.Order;

    var messageId : Nat = 0;

    private func hashMessage(n : Nat) : Hash.Hash {
        return Text.hash(Nat.toText(n));
    };

	let wall = HashMap.HashMap<Nat, Message>(0, Nat.equal,hashMessage);

  public shared ({caller}) func writeMessage(c : Content) : async Nat {
      
      messageId += 1;
      var message : Message = {
          vote = 0;
          content = c;
          creator = caller;
      };

      wall.put(messageId,message);
      
      return messageId;
  };

  public shared query func getMessage(messageId : Nat) : async Result.Result<Message,Text> {
       let messageInfo : ?Message = wall.get(messageId);
       switch(messageInfo) {
        case(null) { return #err("id " #  Nat.toText(messageId) # " not found")  };
        case(?messageInfo) { return #ok(messageInfo) };
       };
  };

  public shared ({caller}) func updateMessage(messageId : Nat,c: Content) : async Result.Result<(),Text>{
    let authPrincipal : Bool = Principal.isAnonymous(caller);
    let messageInfo : ?Message = wall.get(messageId);

    if(authPrincipal){
      return #err("you try to modify a message without being authenticated or the message does not belong to you");
    };

    switch(messageInfo){
      case(null) { return #err("id " #  Nat.toText(messageId) # " not found")  };
      case(?messageInfo) {
        if(messageInfo.creator != caller){return #err("You are not the creator of the message you are trying to update.");};

        let updateMessageData : Message = {
          vote = messageInfo.vote;
          content = c;
          creator = messageInfo.creator;
        };

        wall.put(messageId,updateMessageData);

        return #ok();
      };
    }
  };

  public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
    let messageInfo : ?Message = wall.get(messageId);

		switch (messageInfo) {
      case(null) { return #err("id " #  Nat.toText(messageId) # " not found")  };
      case(?messageInfo) {
        if(messageInfo.creator != caller){return #err("You are not the creator of the message you are trying to update.");};

				ignore wall.remove(messageId);
        return #ok();
      };
	  };
  };

  public shared func upVote(messageId : Nat) : async Result.Result<(),Text> {
    let messageInfo : ?Message = wall.get(messageId);

    switch(messageInfo) {
      case(null) { return #err("id " #  Nat.toText(messageId) # " not found")  };
      case(?messageInfo) {

        let updateVoteMessageData : Message = {
          vote = messageInfo.vote + 1;
          content = messageInfo.content;
          creator = messageInfo.creator;
        };

        wall.put(messageId,updateVoteMessageData);

        return #ok();
      };
    }
  };

  public shared func downVote(messageId : Nat) : async Result.Result<(),Text> {
    let messageInfo : ?Message = wall.get(messageId);

    switch(messageInfo) {
      case(null) { return #err("id " #  Nat.toText(messageId) # " not found")  };
      case(?messageInfo) {

        let updateVoteMessageData : Message = {
          vote = messageInfo.vote - 1;
          content = messageInfo.content;
          creator = messageInfo.creator;
        };

        wall.put(messageId,updateVoteMessageData);

        return #ok();
      };
    }
  };

  public shared query func getAllMessage() : async [Message] {
    let bufferMessage = Buffer.Buffer<Message>(0);

    for (message in wall.vals()) {
      bufferMessage.add(message);
    };

    return Buffer.toArray<Message>(bufferMessage);
  };

  private func compareVote(a : Message ,b : Message) : Order {
    if (a.vote > b.vote) { #less } else if (a.vote ==  b.vote) { #equal } else { #greater }
  };

  public shared func getAllMessagesRanked() : async [Message] {
     let  messageIter :Iter.Iter<Message> = wall.vals();
     let  orderMessage : Iter.Iter<Message> = Iter.sort(messageIter,compareVote);
     return Iter.toArray<Message>(orderMessage);

  }
}