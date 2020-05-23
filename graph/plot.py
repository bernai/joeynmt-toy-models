# https://matplotlib.org/tutorials/introductory/pyplot.html
import matplotlib.pyplot as plt

plt.plot([2, 5, 7, 10, 15, 20, 30, 40, 80, 100], [22.3, 22.6, 22.6, 22.8, 22.6, 22.5, 22.6, 22.6, 22.4, 22.3])
plt.ylabel('BLEU')
plt.xlabel('BEAM SIZE')
plt.show()
