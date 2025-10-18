import java.util.Arrays;

String inputCode;
ArrayList<Command> codeCommands;
byte[] world;
int pointer = 0;
int pixelW = 20;

void setup() {
  size(600, 600);
  world = new byte[(width / pixelW) * (height / pixelW) + 10];
  inputCode = String.join("\n", loadStrings("code.txt"));
  codeCommands = convert(inputCode);
  //for (Command c : codeCommands) print(c + " ");
  //println();
  parse(codeCommands);
}

void draw() {
  noStroke();
  for (int i = 0; i < width / pixelW; i++) {
    for (int j = 0; j < height / pixelW; j++) {
      int index = i + j * width / pixelW;
      fill(world[index] & 0xFF);
      rect(i * pixelW, j * pixelW, pixelW, pixelW);
    }
  }
}

ArrayList<Command> convert(String code) {
  String onlyBFChars = code.replaceAll("\\{.*?\\}|[\\{\\}]|[^<>+\\-\\[\\]\\.  ,]", "");
  ArrayList<Command> commandList = new ArrayList<>();
  for (int i = 0; i < onlyBFChars.length(); i++) {
    char c = onlyBFChars.charAt(i);
    switch(c) {
    case '<':
    case '>':
    case '+':
    case '-':
      int count = 1;
      for (int j = i + 1; j < onlyBFChars.length(); j++) {
        if (onlyBFChars.charAt(j) == c) {
          count++;
        } else {
          break;
        }
      }
      CommandType command = c == '<' ? CommandType.LEFT : c == '>' ? CommandType.RIGHT : c == '+' ? CommandType.INC : CommandType.DEC;
      commandList.add(new Command(command, count));
      i += count - 1;
      break;
    case '[':
      commandList.add(new Command(CommandType.STARTIF));
      break;
    case ']':
      commandList.add(new Command(CommandType.ENDIF));
      break;
    case '.':
      commandList.add(new Command(CommandType.OUTPUT));
      break;
    case ',':
      commandList.add(new Command(CommandType.INPUT));
      break;
    }
  }
  boolean didChange = true;
  while (didChange) {
    didChange = false;
    for (int i = commandList.size() - 2; i >= 0; i--) {
      Command here = commandList.get(i);
      if (here.arg == 0 && (here.command == CommandType.LEFT || here.command == CommandType.RIGHT || here.command == CommandType.INC || here.command == CommandType.DEC)) {
        commandList.remove(i);
        didChange = true;
        continue;
      }
      Command next = commandList.get(i + 1);
      switch(here.command) {
      case LEFT:
        switch(next.command) {
        case LEFT:
          here.arg += next.arg;
          commandList.remove(i + 1);
          didChange = true;
          break;
        case RIGHT:
          if (next.arg > here.arg) {
            next.arg -= here.arg;
            commandList.remove(i);
            didChange = true;
          } else {
            here.arg -= next.arg;
            commandList.remove(i + 1);
            didChange = true;
          }
          break;
        default:
          break;
        }
        break;
      case RIGHT:
        switch(next.command) {
        case RIGHT:
          here.arg += next.arg;
          commandList.remove(i + 1);
          didChange = true;
          break;
        case LEFT:
          if (next.arg > here.arg) {
            next.arg -= here.arg;
            commandList.remove(i);
            didChange = true;
          } else {
            here.arg -= next.arg;
            commandList.remove(i + 1);
            didChange = true;
          }
          break;
        default:
          break;
        }
        break;
      case INC:
        switch(next.command) {
        case INC:
          here.arg += next.arg;
          commandList.remove(i + 1);
          didChange = true;
          break;
        case DEC:
          if (next.arg > here.arg) {
            next.arg -= here.arg;
            commandList.remove(i);
            didChange = true;
          } else {
            here.arg -= next.arg;
            commandList.remove(i + 1);
            didChange = true;
          }
          break;
        default:
          break;
        }
        break;
      case DEC:
        switch(next.command) {
        case DEC:
          here.arg += next.arg;
          commandList.remove(i + 1);
          break;
        case INC:
          if (next.arg > here.arg) {
            next.arg -= here.arg;
            commandList.remove(i);
          } else {
            here.arg -= next.arg;
            commandList.remove(i + 1);
          }
          break;
        default:
          break;
        }
        break;
      case STARTIF:
        if (next.command == CommandType.ENDIF) {
          commandList.remove(i + 1);
          commandList.remove(i);
          didChange = true;
        } else if (next.command == CommandType.DEC && i < commandList.size() - 2 && commandList.get(i + 2).command == CommandType.ENDIF) {
          commandList.remove(i + 2);
          commandList.remove(i + 1);
          here.command = CommandType.SET;
          here.arg = 0;
          didChange = true;
        }
        break;
      case SET:
        switch(next.command) {
        case SET:
          commandList.remove(i);
          didChange = true;
          break;
        case INC:
          here.arg += next.arg;
          commandList.remove(i + 1);
          didChange = true;
          break;
        case DEC:
          here.arg -= next.arg;
          commandList.remove(i + 1);
          didChange = true;
          break;
        default:
          break;
        }
        break;
      default:
        break;
      }
    }
  }

  ArrayList<Integer> starts = new ArrayList<>();
  for (int i = 0; i < commandList.size(); i++) {
    Command c = commandList.get(i);
    if (c.command == CommandType.STARTIF) {
      starts.add(i);
    } else if (c.command == CommandType.ENDIF) {
      int startIndex = starts.remove(starts.size() - 1);
      commandList.get(startIndex).arg = i;
      c.arg = startIndex;
    }
  }

  return commandList;
}

void parse(ArrayList<Command> commandList) {
  parse(commandList, (byte)0);
}

void parse(ArrayList<Command> commandList, byte inputVal) {
  for (int i = 0; i < commandList.size(); i++) {
    Command c = commandList.get(i);
    switch(c.command) {
    case LEFT:
      pointer -= c.arg;
      if (pointer < 0) {
        throw new IndexOutOfBoundsException("Pointer is less than 0");
      }
      break;
    case RIGHT:
      pointer += c.arg;
      if (pointer >= world.length) {
        world = Arrays.copyOf(world, pointer + 1);
      }
      break;
    case INC:
      world[pointer] += c.arg;
      break;
    case DEC:
      world[pointer] -= c.arg;
      break;
    case STARTIF:
      if (world[pointer] == 0) {
        i = c.arg;
      }
      break;
    case ENDIF:
      if (world[pointer] != 0) {
        i = c.arg;
      }
      break;
    case INPUT:
      world[pointer] = inputVal;
      break;
    case OUTPUT:
      println(world[pointer]);
      break;
    case SET:
      world[pointer] = (byte)c.arg;
      break;
    }
  }
}
