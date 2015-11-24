from random import shuffle


def generate_taskfile():
  triplets = []
  with open('source.csv', 'r') as f:
    for line in f:
      triplets.append(line.strip().split(','))

  num_stimuli_each_set = len(triplets) / 3
  for i in range(0, 3):
    stimuli200 = []
    stimuli100_1 = []
    stimuli100_2 = []
    stimuli33 = []
    for triplet in triplets[i*num_stimuli_each_set: (i+1)*num_stimuli_each_set]:
      new_triplet = [url for url in triplet]
      stimuli33.append(new_triplet)
    shuffle(stimuli33)
    stimuli100_1.extend(stimuli33)
    shuffle(stimuli33)
    stimuli100_2.extend(stimuli33)
    stimuli33 = []

    for triplet in triplets[i*num_stimuli_each_set: (i+1)*num_stimuli_each_set]:
      new_triplet = [url for url in triplet]
      tmp = new_triplet[0]
      new_triplet[0] = new_triplet[1]
      new_triplet[1] = tmp
      stimuli33.append(new_triplet)
    shuffle(stimuli33)
    stimuli100_1.extend(stimuli33)
    shuffle(stimuli33)
    stimuli100_2.extend(stimuli33)
    stimuli33 = []

    for triplet in triplets[i*num_stimuli_each_set: (i+1)*num_stimuli_each_set]:
      new_triplet = [url for url in triplet]
      tmp = new_triplet[0]
      new_triplet[0] = new_triplet[2]
      new_triplet[2] = tmp
      stimuli33.append(new_triplet)
    shuffle(stimuli33)
    stimuli100_1.extend(stimuli33)
    shuffle(stimuli33)
    stimuli100_2.extend(stimuli33)

    stimuli200.extend(stimuli100_1)
    stimuli200.extend(stimuli100_2)
    with open('tri_set' + str(i + 1) + '.txt', 'w') as f:
      for s in stimuli200:
        f.write(','.join(s) + '\n')

def duplicate_taskfile():
  num_source_dict = {
    1: 'tri_set1.txt',
    2: 'tri_set2.txt',
    3: 'tri_set3.txt',
  }
  for i in range(1, 4):
    j = i + 3
    while j <= 30:
      with open(num_source_dict[i], 'r') as f,\
         open('tri_set' + str(j) + '.txt', 'w') as g:
        for line in f:
          g.write(line)
      j += 3

duplicate_taskfile()








