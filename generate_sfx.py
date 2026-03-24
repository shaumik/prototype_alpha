import math
import struct
import wave
import random
import os

def create_wav(filename, samples, sample_rate=44100):
    with wave.open(filename, 'w') as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(sample_rate)
        # Convert float samples (-1.0 to 1.0) to 16-bit integers
        int_samples = [max(-32768, min(32767, int(s * 32767.0))) for s in samples]
        # Pack integers to binary string
        packed = struct.pack('<' + 'h' * len(int_samples), *int_samples)
        wav_file.writeframes(packed)

def generate_shoot(duration=0.15, sample_rate=44100):
    samples = []
    num_samples = int(duration * sample_rate)
    freq_start = 800.0
    freq_end = 200.0
    for i in range(num_samples):
        t = i / sample_rate
        # Exponential frequency decay
        freq = freq_start * ((freq_end/freq_start) ** (t/duration))
        # Square wave
        val = 1.0 if math.sin(2 * math.pi * freq * t) > 0 else -1.0
        # Envelope: quick attack, fast decay
        env = max(0, 1 - (t / duration)) ** 2
        samples.append(val * env * 0.4)
    return samples

def generate_noise_burst(duration=0.2, sample_rate=44100):
    samples = []
    num_samples = int(duration * sample_rate)
    for i in range(num_samples):
        t = i / sample_rate
        val = random.uniform(-1.0, 1.0)
        env = max(0, 1 - (t / duration)) ** 3
        samples.append(val * env * 0.5)
    return samples

def generate_explosion(duration=0.6, sample_rate=44100):
    samples = []
    num_samples = int(duration * sample_rate)
    freq = 150.0
    phase = 0.0
    for i in range(num_samples):
        t = i / sample_rate
        val_noise = random.uniform(-1.0, 1.0)
        
        phase += freq / sample_rate
        val_sq = 1.0 if (phase % 1.0) < 0.5 else -1.0
        val = val_noise * 0.6 + val_sq * 0.4
        
        freq = max(20.0, freq - (freq * 2.0 / sample_rate))
        env = max(0, 1 - (t / duration)) ** 1.5
        samples.append(val * env * 0.6)
    return samples

def generate_player_damage(duration=0.4, sample_rate=44100):
    samples = []
    num_samples = int(duration * sample_rate)
    freq_start = 300.0
    freq_end = 50.0
    for i in range(num_samples):
        t = i / sample_rate
        freq = freq_start * ((freq_end/freq_start) ** (t/duration))
        phase = (t * freq) % 1.0
        val = 2.0 * phase - 1.0
        env = max(0, 1 - (t / duration)) ** 2
        samples.append(val * env * 0.6)
    return samples

if __name__ == "__main__":
    out_dir = "/Users/shaumikmondal/programming/prototype_alpha/assets/audio"
    os.makedirs(out_dir, exist_ok=True)
    
    create_wav(os.path.join(out_dir, "shoot.wav"), generate_shoot())
    create_wav(os.path.join(out_dir, "hit.wav"), generate_noise_burst(duration=0.15))
    create_wav(os.path.join(out_dir, "explosion.wav"), generate_explosion(duration=0.8))
    create_wav(os.path.join(out_dir, "player_damage.wav"), generate_player_damage(duration=0.5))
    print("Sound generation complete!")
