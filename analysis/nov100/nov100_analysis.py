from collections import defaultdict
import matplotlib.pyplot as plt
import plotly.plotly as py
import matplotlib.image as mpimg
from matplotlib.widgets import Button
import urllib2
import os


def get_workerid_data_dict():
  workerid_data_dict = defaultdict(list)
  with open('/Users/a67/Project/DeepLearning/simi_triplet/data/nov100/triplet.csv') as f:
    for i, line in enumerate(f):
      if i == 0:
        continue
      line = line.strip()
      data_list = line.split(',')
      worker_id = int(data_list[0])
      trial_type = int(data_list[4])
      if trial_type == 1:
        continue
      if trial_type == 3:
        continue
      if len(data_list) >= 15:
        for i in range(10, len(data_list)):
          if data_list[i] in ['0', '1', '2']:
            pivot = i
            break
        for i in range(10, 15):
          data_list[i] = data_list[i + (pivot - 10)]
      useful_data_list = data_list[8: 10]
      useful_data_list.extend(data_list[12: 15])
      workerid_data_dict[worker_id].append(useful_data_list)
  return workerid_data_dict

# Get a dict whose key is worker_id and value is a dict whose key is made as:
#   "img1=-=img2=-=img3" and value as a list of list [[resp11, resp12], [resp21, resp22]]
def get_workerid_response_dict():
  workerid_data_dict = get_workerid_data_dict()
  workerid_response_dict = dict()
  for worker_id in workerid_data_dict:
    data_list = workerid_data_dict[worker_id]
    stimulus_tworesponse_dict = defaultdict(list)
    for entry in data_list:
      stimulus_str = '=-='.join(entry[2:])
      stimulus_tworesponse_dict[stimulus_str].append(entry[:2])
    workerid_response_dict[worker_id] = stimulus_tworesponse_dict
  return workerid_response_dict

def get_subject_consistency():
  workerid_response_dict = get_workerid_response_dict()
  workerid_consistency_dict = dict()
  for worker_id in workerid_response_dict:
    stimulus_tworesponse_dict = workerid_response_dict[worker_id]
    num_diff = 0
    num_total = len(stimulus_tworesponse_dict)
    for stimulus in stimulus_tworesponse_dict:
      two_response = stimulus_tworesponse_dict[stimulus]
      if set(two_response[0]) != set(two_response[1]):
        num_diff += 1
    consistency = float((num_total - num_diff)) / float(num_total)
    workerid_consistency_dict[worker_id] = consistency
  return workerid_consistency_dict

def init_triplet_responsecount_dict():
  workerid_response_dict = get_workerid_response_dict()
  triplet_responsecount_dict = defaultdict(dict)
  # initialize
  for worker_id in workerid_response_dict:
    stimulus_tworesponse_dict = workerid_response_dict[worker_id]
    for stimulus in stimulus_tworesponse_dict:
      triplet = stimulus.split('=-=')
      triplet.sort()
      resp1_str = '=-='.join([triplet[0], triplet[1]])
      resp2_str = '=-='.join([triplet[0], triplet[2]])
      resp3_str = '=-='.join([triplet[1], triplet[2]])
      triplet_responsecount_dict[stimulus][resp1_str] = 0
      triplet_responsecount_dict[stimulus][resp2_str] = 0
      triplet_responsecount_dict[stimulus][resp3_str] = 0
  return triplet_responsecount_dict

def get_majority_vote(order_of_target=1):
  workerid_response_dict = get_workerid_response_dict()
  triplet_responsecount_dict = init_triplet_responsecount_dict()
  for worker_id in workerid_response_dict:
    stimulus_tworesponse_dict = workerid_response_dict[worker_id]
    for stimulus in stimulus_tworesponse_dict:
      two_response = stimulus_tworesponse_dict[stimulus]
      resp1 = two_response[0]; resp2 = two_response[1]
      resp1.sort(); resp2.sort()
      resp1_str = '=-='.join(resp1); resp2_str = '=-='.join(resp2)
      try:
        triplet_responsecount_dict[stimulus][resp1_str] += 1
      except:
        continue
      try:
        triplet_responsecount_dict[stimulus][resp2_str] += 1
      except:
        continue

  triplet_majority_dict = defaultdict(list)
  for triplet in triplet_responsecount_dict:
    response_count_dict = triplet_responsecount_dict[triplet]
    response_count_tuples =\
      [(response_count_dict[resp], resp) for resp in response_count_dict]
    response_count_tuples.sort(reverse=True)
    total_count = sum([response_count_dict[resp] for resp in response_count_dict])
    target_resp = response_count_tuples[order_of_target - 1][1]
    target_count = response_count_tuples[order_of_target - 1][0]
    count_ratio = float(target_count) / float(total_count)
    triplet_majority_dict[triplet].extend(
      [
        target_resp,
        target_count,
        count_ratio
      ]
    )
  return triplet_majority_dict

def get_response_inconsistency():
  workerid_response_dict = get_workerid_response_dict()
  triplet_inconsistency_dict = dict()
  for worker_id in workerid_response_dict:
    stimulus_tworesponse_dict = workerid_response_dict[worker_id]
    for stimulus in stimulus_tworesponse_dict:
      if stimulus not in triplet_inconsistency_dict:
        triplet_inconsistency_dict[stimulus] = [0, 0]
      two_response = stimulus_tworesponse_dict[stimulus]
      triplet_inconsistency_dict[stimulus][1] += 1
      if set(two_response[0]) != set(two_response[1]):
        triplet_inconsistency_dict[stimulus][0] += 1
  for stimulus in triplet_inconsistency_dict:
    count_inconsistent = triplet_inconsistency_dict[stimulus][0]
    count_total = triplet_inconsistency_dict[stimulus][1]
    triplet_inconsistency_dict[stimulus] = float(count_inconsistent) / float(count_total)
  return triplet_inconsistency_dict

def get_sorted_tripletstr_list():
  workerid_response_dict = get_workerid_response_dict()
  tripletstr_dict = dict()
  for worker_id in workerid_response_dict:
    stimulus_tworesponse_dict = workerid_response_dict[worker_id]
    for stimulus in stimulus_tworesponse_dict:
      tripletstr_dict[stimulus] = 1
  tripletstr_list = [key for key in tripletstr_dict]
  tripletstr_list.sort()
  return tripletstr_list

def generate_worker_gt_consistency_vector():
  workerid_response_dict = get_workerid_response_dict()
  triplet_majority_dict = get_majority_vote()
  worker_gt_consistency_dict = defaultdict(list)
  sorted_tripletstr_list = get_sorted_tripletstr_list()
  for worker_id in workerid_response_dict:
    stimulus_tworesponse_dict = workerid_response_dict[worker_id]
    for stimulus in sorted_tripletstr_list:
      two_response = stimulus_tworesponse_dict[stimulus]
      resp1 = two_response[0]; resp2 = two_response[1]
      resp1.sort(); resp2.sort()
      resp1_str = '=-='.join(resp1); resp2_str = '=-='.join(resp2)
      if resp1_str == triplet_majority_dict[stimulus][0] or\
          resp2_str == triplet_majority_dict[stimulus][0]:
        worker_gt_consistency_dict[worker_id].append(1)
      else:
        worker_gt_consistency_dict[worker_id].append(0)
  workerid_agree_dict = dict()
  for worker_id in worker_gt_consistency_dict:
    workerid_agree_dict[worker_id] = sum(worker_gt_consistency_dict[worker_id])
  return workerid_agree_dict

def generate_histogram(array, title, xlabel, ylabel, filename):
  plt.hist(array)
  plt.title(title)
  plt.xlabel(xlabel)
  plt.ylabel(ylabel)
  fig = plt.gcf()
  plot_url = py.plot_mpl(fig, filename=filename)

def generate_triplet_images():
  majorities = get_majority_vote(1)
  second_majorities = get_majority_vote(2)
  third_majorities = get_majority_vote(3)
  report_tuples = [
    (
      round(majorities[triplet_str][2], 2), # count ratio of 1st majority
      round(second_majorities[triplet_str][2], 2), # count ratio of second
      round(third_majorities[triplet_str][2], 2), # count rati of third
      triplet_str, # a string representing a triplet as img1=-=img2=-=img3
      majorities[triplet_str][0], # a string representing response of 1st majority as resp1=-=resp2
      second_majorities[triplet_str][0], # string for response of 2nd majority
      third_majorities[triplet_str][0], # string for response of third
    ) for triplet_str in majorities
  ]
  report_tuples.sort(reverse=True)

  classified_report_tuples = [
    [t for t in report_tuples if t[0] >= 0.8 and t[1] <= 0.2 and t[2] <= 0.1],
    [t for t in report_tuples if t[0] <= 0.8 and t[0] >= 0.6 and\
                                 t[1] > 0.2 and t[1] < 0.4 and t[2] <= 0.2],
    [t for t in report_tuples if t[0] >= 0.45 and t[0] < 0.6 and t[2] < 0.2],
    [t for t in report_tuples if t[0] < 0.45],
  ]
  ### Lengths of classified_report_tuples: 12, 28, 24, 7

  imgstr_imgdata_dict = dict()
  for rt in report_tuples:
    triplet_str = rt[3]
    imgstrs = triplet_str.split('=-=')
    for imgstr in imgstrs:
      imgstr_imgdata_dict[imgstr] = None

  images_folder = os.path.expanduser("~/Desktop/nov100_analysis_images_downloaded")
  if not os.path.isdir(images_folder):
    print 'Images not found locally. Downloading images to: ' + images_folder
    print 'You can delete it from desktop after this program is not needed.'
    os.system('mkdir ' + images_folder)
    for i, imgstr in enumerate(imgstr_imgdata_dict):
      img_data = urllib2.urlopen('http://52.23.229.132/' + imgstr + '.jpg')
      with open(images_folder + '/' + imgstr.split('/')[-1] + '.jpg', 'w') as f:
        f.write(img_data.read())
    print 'Download complete.'

  print 'Preloading images... '
  for i, imgstr in enumerate(imgstr_imgdata_dict):
    imgstr_imgdata_dict[imgstr] =\
      plt.imread(images_folder + '/' + imgstr.split('/')[-1] + '.jpg', format='JPG')
  print 'Preloading complete'

  fig = plt.figure()
  axes = plt.gca()
  num_triset_each_row = 3
  row_num = 7 # 10 triplets from the first 3 groups, 7 from the last
  col_num = 9 # 3+2+2+2, number of images each row
  subplot_num = 1
  for crts in classified_report_tuples[3:4]:
    for crt in crts[:7]:
      triplet_imgstrs = crt[3].split('=-=')
      fir_sec_thd_majresp_imgstrs = [crt[i].split('=-=') for i in range(4, 7)]
      for imgstr in triplet_imgstrs:
        print row_num, col_num, subplot_num
        panel = fig.add_subplot(row_num, col_num, subplot_num)
        img = imgstr_imgdata_dict[imgstr]
        imgplot = plt.imshow(img)
        plt.axis('off')
        # panel.set_title(imgstr)
        subplot_num += 1
      for maj_imgstrs in fir_sec_thd_majresp_imgstrs:
        for imgstr in maj_imgstrs:
          panel = fig.add_subplot(row_num, col_num, subplot_num)
          img = imgstr_imgdata_dict[imgstr]
          imgplot = plt.imshow(img)
          plt.axis('off')
          # panel.set_title(imgstr)
          subplot_num += 1
  fig.subplots_adjust(wspace=0.0)
  plt.show()

def report_majorityvote_stat():
  majorities = get_majority_vote(1)
  second_majorities = get_majority_vote(2)
  third_majorities = get_majority_vote(3)
  generate_histogram(
      [majorities[key][2] for key in majorities],
      'Majority Vote Ratio For Each Triplet',
      'Ratio',
      'Triplet',
      'majority_vote_ratio'
  )
  report_tuples = [
    (
      round(majorities[key][2], 2),
      round(second_majorities[key][2], 2),
      round(third_majorities[key][2], 2)
    ) for key in majorities
  ]
  report_tuples.sort(reverse=True)

  for t in report_tuples:
    print t[0], '\t\t\t', t[1], '\t\t\t\t', t[2]

def report_selfconsistency_gtconsistency_by_workerid():
  s = get_subject_consistency()
  b = generate_worker_gt_consistency_vector()
  print 'workerid, self-consistency, gt_consistency'
  for i in range(1, 11):
    print i, s[i], b[i]

def report_tripletindex_with_twoworkerchoicesindex():
  workerid_response_dict = get_workerid_response_dict()
  triplet_workerchoices_dict = defaultdict(dict)
  for worker_id in workerid_response_dict:
    stimulus_tworesponse_dict = workerid_response_dict[worker_id]
    for triplet in stimulus_tworesponse_dict:
      two_response = stimulus_tworesponse_dict[triplet]
      resp1_str = ','.join([imgstr.split('/')[-1][1:] for imgstr in two_response[0]])
      resp2_str = ','.join([imgstr.split('/')[-1][1:] for imgstr in two_response[1]])
      triplet_workerchoices_dict[triplet][worker_id] = ','.join([resp1_str, resp2_str])

  with open('report_triplet_with_twoworkerchoices.tsv', 'w') as f:
    for i, triplet in enumerate(triplet_workerchoices_dict):
      triplet_str = ','.join([t.split('/')[-1][1:] for t in triplet.split('=-=')])
      print_list = [str(i), triplet_str]
      for worker_id in range(1, 11):
        print_list.append(triplet_workerchoices_dict[triplet][worker_id])
      f.write('\t'.join(print_list) + '\n')


# get_response_inconsistency()
# generate_groundtruthvector()

# report_selfconsistency_gtconsistency_by_workerid

# report_majorityvote_stat

generate_triplet_images()

# report_tripletindex_with_twoworkerchoicesindex()




















