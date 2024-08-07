import numpy as np
from matplotlib import pyplot as plt
time_series = np.array(list(np.linspace(7.1, 1.3, 100)) + list(np.linspace(1.3, 3.4, 100)) + list(np.linspace(3.4, 0, 100)) + list(np.linspace(0, 5.2, 100)) + list(np.linspace(5.2, 1.7, 100)) + list(np.linspace(1.7, 2.2, 100)) + list(np.linspace(2.2, 2.0, 100)) + list(np.linspace(2.0, 7.1, 100)))
time_series = [0] + list(time_series)
plt.plot(time_series)
plt.show()

def one_pass_bar_algorithm(time_series):
    maxima, minima = [], []
    direction = 1

    # add a very small point at the front of the time_series
    time_series = [time_series[0] - 1e-6] + time_series

    for t in range(1, len(time_series)):
        if (time_series[t] - time_series[t-1]) * direction < 0:
            if direction == 1:
                maxima.append((t-1, time_series[t-1]))
            else:
                minima.append((t-1, time_series[t-1]))
            direction = -direction
        else:
          if direction == 1 and len(maxima) != 0 and time_series[t] > maxima[0][1]:
              output_bar(maxima.pop(), minima.pop())
          elif direction == -1 and len(minima) != 0 and time_series[t] < minima[0][1]:
              output_bar(maxima.pop(), minima.pop())
    output_remaining_bars(maxima, minima)

def output_bar(max_value, min_value):
    print(f"Bar: ({max_value[0]}, {max_value[1]}) to ({min_value[0]}, {min_value[1]})")

def output_remaining_bars(maxima, minima):
    for i in range(min(len(maxima), len(minima))):
      print(f"Bar: ({maxima[i][0]}, {maxima[i][1]}) to ({minima[i][0]}, {minima[i][1]})")
one_pass_bar_algorithm(list(time_series))