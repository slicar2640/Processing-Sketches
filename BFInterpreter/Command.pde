class Command {
  CommandType command;
  int arg = -1;
  Command(CommandType command, int arg) {
    this.command = command;
    this.arg = arg;
  }
  
  Command(CommandType command) {
    this.command = command;
  }
  
  String toString() {
    return command.toString() + (arg != -1 ? "(" + arg + ")" : "");
  }
}

enum CommandType {
  LEFT,
  RIGHT,
  INC,
  DEC,
  STARTIF,
  ENDIF,
  INPUT,
  OUTPUT,
  SET
}
