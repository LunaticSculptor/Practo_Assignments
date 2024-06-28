from abc import ABC, abstractmethod

# Observer Interface
class Observer(ABC):
    @abstractmethod
    def update(self, color):
        pass

# Things
class Thing(Observer):
    def __init__(self, name, colors):
        self.name = name
        self.colors = set(colors)
        self.subscribed = False

    def update(self, color):
        if self.subscribed and color in self.colors:
            if self.name == 'Frog':
                print(f"I’m Frog! I am {color} today.")
            else:
                print(f"I’m {self.name}! I’m sometimes {color}!")

# Thing Instances
class Salt(Thing):
    def __init__(self):
        super().__init__('Salt', ['White'])

class Frog(Thing):
    def __init__(self):
        super().__init__('Frog', ['Blue', 'Yellow'])

# Command Processor
class CommandProcessor:
    def __init__(self):
        self.things = {
            'salt': Salt(),
            'frog': Frog(),
        }

    def process_command(self, command):
        parts = command.split()
        if not parts:
            return

        cmd = parts[0].lower()
        if cmd == '+salt':
            self.subscribe('salt')
        elif cmd == '-salt':
            self.unsubscribe('salt')
        elif cmd in ['white', 'green', 'red', 'blue', 'black', 'yellow']:
            self.notify_color(cmd)
        elif cmd == 'list':
            self.print_subscribed()
        elif cmd == 'exit':
            return True
        else:
            print("Unknown command")

    def subscribe(self, thing_name):
        if thing_name in self.things:
            self.things[thing_name].subscribed = True
            print(f"Subscribed {thing_name.capitalize()} for notifications.")

    def unsubscribe(self, thing_name):
        if thing_name in self.things:
            self.things[thing_name].subscribed = False
            print(f"Unsubscribed {thing_name.capitalize()} from notifications.")

    def notify_color(self, color):
        for thing in self.things.values():
            thing.update(color)

    def print_subscribed(self):
        subscribed_list = [thing.name for thing in self.things.values() if thing.subscribed]
        if subscribed_list:
            print("Subscribed things:", ", ".join(subscribed_list))
        else:
            print("No things currently subscribed.")

# Main Application Loop
def main():
    command_processor = CommandProcessor()
    print("Welcome to the notification system!")
    while True:
        command = input("Enter a command: ").strip()
        if command_processor.process_command(command):
            print("Exiting...")
            break

if __name__ == "__main__":
    main()
