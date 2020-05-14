class Score {
  final int id;
  final String gameid;
  final DateTime scoreDate;
  final int userScore;
  final String userName;

  //set score to these 5 variables
  Score(
      {this.id = 0,
      this.scoreDate,
      this.userScore,
      this.gameid,
      this.userName});

  //set the actual values of the variables
  Score.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        gameid = map['gameid'],
        //time since 1970
        scoreDate =DateTime.fromMillisecondsSinceEpoch(map['scoreDate']),
        userName = map['userName'],
        userScore = map['userScore'];
  Map<String, dynamic> toMap() {
    return {
      'scoreDate': scoreDate.millisecondsSinceEpoch,
      'gameid': gameid,
      'userName': userName,
      'userScore': userScore,
    };
  }

  // Implement toString to make it easier to see information about
  // each score when using the print statement.

  @override
  String toString() {
    return '$userScore,$scoreDate,$id';
  }
}
