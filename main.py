import numpy as np
import pandas as pd
from collections import Counter
import time
import argparse
from pythonosc import udp_client
from pythonosc.dispatcher import Dispatcher
from pythonosc.osc_server import BlockingOSCUDPServer
from pythonosc.osc_server import AsyncIOOSCUDPServer
from pythonosc.dispatcher import Dispatcher
import asyncio


referenceMode = "Dorian"

chords_midi_dict = {
    'C': [0, 15],
    'C7': [0, 10],
    'Cm': [0, 14],
    'Cd': [0, 11],
    'C#': [1, 16],
    'C#7': [1, 11],
    'C#m': [1, 15],
    'C#d': [1, 12],
    'D': [2, 17],
    'D7': [2, 12],
    'Dm': [2, 16],
    'Dd': [2,12],
    'Ddim': [2, 8],
    'C#d': [1, 12],
    'Eb': [3, 3],
    'Eb7': [3, 11],
    'Ebm': [-2, 6],
    'Ebd': [3,14],
    'E': [4, 11],
    'E7': [4, 14],
    'Em': [-1, 4],
    'Ed': [-2,4],
    'F': [-3, 5],
    'F7': [-7, 3],
    'Fm': [-4, 5],
    'Fd': [-7, 3],
    'F#': [-2, 6],
    'F#7': [-6, 4],
    'F#m': [-3, 6],
    'F#d': [-8, 5],
    'G': [-1, 7],
    'G7': [-5, 5],
    'Gm': [-2, 7],
    'Gd': [-5, 5],
    'Ab': [-3, 13],
    'Ab7': [-4, 6],
    'Abm': [-4, 11],
    'Abd': [-4, 7],
    'Abdim':[-4, 2],
    'A': [-3, 13],
    'A7': [-3, 7],
    'Am': [-3, 12],
    'Ad': [-3, 8],
    'Adim': [-3, 3],
    'Bb': [-2, 14],
    'Bb7': [-2, 8],
    'Bbm': [-2, 13],
    'Bbd': [-1, 12],
    'B': [-1, 15],
    'B7': [-1, 9],
    'Bm': [-1, 14],
    'B#d': [-1, 11],
    'Bdim': [-1, 5],
    }

counter = 1
lastChord = 'Cm';
oscInterrupt = True

def filter_handler(address, *args):
    global referenceMode, pythonSends
    referenceMode = args[0]
    oscInterrupt = False
    print(referenceMode)


dispatcher = Dispatcher()
dispatcher.map("/Python/sunMode", filter_handler)

ip = "127.0.0.1"
port = 57121


async def loop():
    """Example main loop that only runs for 10 iterations before finishing"""
    global referenceMode
    global oscInterrupt
    global lastChord
    global pythonSends
    start = True
    while counter > 0:

            # Read Chord Collection file
            data = pd.read_csv("data/" + referenceMode + ".csv")

            # Generate Bigrams
            n = 2
            chords = data['chords'].values
            ngrams = zip(*[chords[i:] for i in range(n)])
            bigrams = [" ".join(ngram) for ngram in ngrams]

            bigrams[:5]

            def predict_next_state(chord: str, data: list = bigrams):
                """Predict next chord based on current state."""
                # create list of bigrams which stats with current chord
                bigrams_with_current_chord = [bigram for bigram in bigrams if bigram.split(' ')[0] == chord]
                # count appearance of each bigram
                count_appearance = dict(Counter(bigrams_with_current_chord))
                # convert apperance into probabilities
                for ngram in count_appearance.keys():
                    count_appearance[ngram] = count_appearance[ngram] / len(bigrams_with_current_chord)
                # create list of possible options for the next chord
                options = [key.split(' ')[1] for key in count_appearance.keys()]
                # create  list of probability distribution
                probabilities = list(count_appearance.values())
                if( not options):
                    options = ['F7','C7']
                    probabilities = [0.5,0.5]
                return np.random.choice(options, p=probabilities)

            def generate_sequence(chord: str = None, start: bool = False, data: list = bigrams, length: int = 4):
                """Generate sequence of defined length."""
                # create list to store future chords
                chords = []
                if start:
                    chords.append(chord)
                bigrams = [" ".join(ngram) for ngram in ngrams]
                for n in range(length):
                    # append next chord for the list
                    chords.append(predict_next_state(chord, bigrams))
                    # use last chord in sequence to predict next chord
                    chord = chords[-1]
                return chords

            def start_osc_communication():
                # argparse helps writing user-friendly commandline interfaces
                parser = argparse.ArgumentParser()
                # OSC server ip
                parser.add_argument("--ip", default='127.0.0.1', help="The ip of the OSC server")
                # OSC server port (check on SuperCollider)
                parser.add_argument("--port", type=int, default=57120, help="The port the OSC server is listening on")

                # Parse the arguments
                args = parser.parse_args()

                # Start the UDP Client
                client = udp_client.SimpleUDPClient(args.ip, args.port)

                return client

            chords = generate_sequence(lastChord,start)
            lastChord = chords[len(chords)-1]
            print('')
            print('')
            print('Generated Chords Sequence:')
            print(chords)
            print('')
            print('')
            print('')
            print('Play the sequence with supercollider:')
            print('lastChord:' + lastChord)
            client = start_osc_communication()
            # Send chords

            for c in chords:
                print(c)
                client.send_message("/Python/Chords", [ chords_midi_dict[c][0], chords_midi_dict[c][1]])
                for i in np.arange(15):
                    await asyncio.sleep((1* (60 / 80))/15)
                    time.sleep((1* (60 / 80))/15)
            start = False
            oscInterrupt = True







async def init_main():
    server = AsyncIOOSCUDPServer((ip, port), dispatcher, asyncio.get_event_loop())
    transport, protocol = await server.create_serve_endpoint()  # Create datagram endpoint and start serving

    await loop()  # Enter main loop of program

    transport.close()  # Clean up serve endpoint


asyncio.run(init_main())




from pythonosc import osc_server

def print_volume_handler(unused_addr, args, volume):
  print("[{0}] ~ {1}".format(args[0], volume))

def print_compute_handler(unused_addr, args, volume):
  try:
    print("[{0}] ~ {1}".format(args[0], args[1](volume)))
  except ValueError: pass


