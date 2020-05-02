class Score {
  final int id;
  final String gameid;
  final DateTime scoreDate;
  final int userScore;
  final String userName;

  Score(
      {this.id = 0,
      this.scoreDate,
      this.userScore,
      this.gameid,
      this.userName});

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
  // each dog when using the print statement.

  @override
  String toString() {
    return '$userScore,$scoreDate,$id';
  }
}
