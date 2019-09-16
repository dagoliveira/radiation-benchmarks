#ifndef INPUT_CONSTANT_H_
#define INPUT_CONSTANT_H_

#define V100_STREAM_MULTIPROCESSOR 1024

#ifndef STREAM_MULTIPROCESSOR
#define STREAM_MULTIPROCESSOR V100_STREAM_MULTIPROCESSOR
#endif

__device__ __constant__ double input_constant[STREAM_MULTIPROCESSOR] = {
		6.10186, 5.30244, 0.810707, 5.80466, 8.1873, 9.94595, 0.905236, 3.83444,
		5.32261, 6.21186, 2.30994, 6.54051, 9.845, 1.6841, 5.19164, 5.2149,
		1.97573, 4.96807, 6.8297, 6.36171, 1.40978, 7.45235, 3.93773, 3.81525,
		3.15698, 3.39548, 1.37867, 6.84404, 2.87493, 7.53891, 9.55352, 8.63703,
		0.642924, 2.69353, 6.63607, 4.47862, 2.34149, 8.50125, 4.6281, 1.15689,
		6.20086, 1.86033, 6.58579, 8.82139, 6.36378, 5.24713, 7.59969, 1.88406,
		6.70663, 8.40455, 7.39367, 9.90289, 7.33509, 3.37995, 7.00958, 4.08531,
		6.57485, 2.7979, 0.301638, 0.219638, 8.26939, 7.70027, 6.35833,
		0.945585, 4.38914, 3.35957, 2.80589, 7.93017, 1.82088, 6.97411, 3.59013,
		9.51943, 1.4505, 7.44015, 4.15624, 8.61832, 9.26151, 2.01788, 4.69128,
		9.69889, 1.38565, 6.72191, 7.58134, 8.38495, 0.112707, 0.415479, 7.2004,
		1.31752, 0.972542, 8.7163, 7.5159, 8.98135, 7.70867, 7.98229, 4.57504,
		4.21835, 9.8014, 8.89665, 0.283124, 9.31907, 9.12336, 5.65178, 1.41582,
		4.89628, 4.71469, 5.9591, 4.28786, 6.08667, 4.69533, 5.31339, 1.4412,
		0.497079, 7.88295, 7.84256, 6.68732, 4.29834, 8.3342, 6.5207, 0.0260773,
		1.72398, 6.27262, 5.02158, 6.11843, 0.287155, 5.94126, 4.53578, 8.58113,
		7.21737, 9.84994, 1.03198, 7.4471, 8.10384, 6.5486, 6.29657, 0.787951,
		3.20043, 2.30928, 5.18458, 6.78254, 3.02364, 1.63573, 9.1948, 4.09504,
		1.65713, 1.46809, 0.673633, 0.349617, 3.51574, 8.62799, 5.65179,
		8.95107, 2.46006, 1.27132, 3.48126, 0.978117, 7.46437, 0.0857456,
		7.81964, 6.32475, 1.11138, 1.32073, 1.65863, 5.36252, 7.21577, 2.82335,
		1.92256, 2.91376, 2.08843, 0.961414, 8.56294, 9.49056, 0.353163,
		7.95404, 4.71384, 0.624288, 3.99575, 9.10474, 6.91255, 6.84447, 1.66784,
		2.98037, 0.0382564, 5.50088, 4.49371, 6.96465, 6.44214, 1.95917,
		7.02087, 8.2194, 2.99733, 4.94593, 5.05227, 6.34729, 6.87325, 1.50513,
		6.51764, 5.02857, 5.56746, 1.1171, 0.124752, 4.52778, 7.94639, 0.477787,
		3.81985, 2.4073, 0.74242, 0.919372, 9.43868, 8.57406, 2.08315, 0.4593,
		8.36223, 4.84756, 4.95138, 2.69417, 6.86672, 7.17315, 6.13715, 1.80074,
		9.47001, 3.25545, 2.33646, 3.68051, 9.33826, 1.4265, 8.3365, 3.0196,
		6.18829, 7.3994, 4.92541, 0.829903, 2.28939, 1.86493, 9.40371, 6.80411,
		1.22159, 8.85819, 8.07906, 2.66561, 2.47385, 0.0371626, 1.96934,
		4.93642, 3.10257, 5.90966, 4.27564, 0.994559, 6.45198, 1.64118, 5.03937,
		6.6503, 8.88927, 4.90274, 1.78997, 3.09308, 3.89966, 0.702048, 2.95798,
		1.20692, 4.15456, 7.80063, 5.37155, 8.72693, 3.46988, 2.77717, 0.26019,
		4.46085, 1.15247, 6.09467, 4.23603, 4.90441, 4.19475, 8.87165, 2.4254,
		5.7839, 5.85664, 2.15565, 9.1276, 4.91272, 4.92798, 7.53002, 4.48749,
		3.33438, 2.69767, 9.22841, 5.09468, 6.65597, 7.0906, 8.72312, 0.151038,
		9.24491, 3.22713, 2.71362, 9.59756, 2.04467, 2.74291, 6.4845, 3.48242,
		6.32516, 5.71847, 5.67671, 1.27807, 2.30421, 3.88226, 3.58564, 9.7425,
		2.43971, 4.90175, 1.18571, 3.64503, 4.48786, 6.65767, 7.1298, 2.15986,
		2.00779, 7.86614, 6.30263, 4.38906, 8.87741, 9.68888, 5.84943, 6.40105,
		9.87199, 4.732, 1.74421, 8.00709, 4.68388, 3.04666, 9.9735, 8.62796,
		8.03646, 5.12177, 7.38259, 0.217351, 2.03899, 7.9397, 8.7058, 3.47233,
		3.48839, 2.47765, 1.97111, 1.05814, 8.0323, 3.12415, 0.614536, 4.78487,
		0.0745039, 9.209, 1.39572, 0.19404, 2.14554, 4.52668, 7.75537, 0.606985,
		8.79163, 1.51992, 8.21348, 8.48208, 5.19999, 4.6541, 1.26868, 7.58982,
		5.87817, 3.54355, 3.59267, 6.53549, 5.4734, 3.40464, 9.91059, 3.55925,
		4.35278, 8.28233, 9.91295, 8.54149, 7.54152, 8.0348, 9.93259, 6.26172,
		1.70762, 2.72882, 8.04612, 7.9283, 4.32317, 3.7298, 0.690491, 4.03001,
		1.27466, 0.579639, 9.94294, 9.43071, 0.31438, 8.07131, 2.032, 5.65981,
		6.64544, 8.12173, 8.84361, 7.87205, 9.75165, 7.41073, 1.20493, 6.42848,
		2.02049, 2.02438, 1.34598, 1.04913, 8.02767, 5.43451, 0.61012, 9.14534,
		7.83376, 7.82242, 6.09045, 2.31259, 2.48404, 9.5065, 5.53652, 0.999674,
		3.54758, 0.836743, 0.485238, 3.78325, 9.43717, 8.32734, 3.0055, 6.32684,
		9.19823, 0.211632, 0.443932, 1.11911, 0.646653, 6.42008, 2.20976,
		0.794746, 4.99551, 0.699255, 0.409945, 8.80998, 8.43668, 3.10002,
		5.55321, 1.59882, 6.16507, 2.75597, 9.69786, 9.20267, 0.106216, 8.82404,
		8.76703, 5.91491, 0.441329, 6.26253, 3.88796, 6.42796, 2.45265, 2.60305,
		8.3176, 1.60158, 2.94642, 4.41016, 5.61797, 5.94922, 5.69678, 7.17157,
		0.420661, 2.78906, 7.13053, 7.38358, 7.54627, 6.32196, 7.70903, 5.87068,
		3.28661, 6.63758, 1.50545, 3.7941, 3.29918, 4.50748, 3.66383, 7.53476,
		6.767, 6.79953, 3.69861, 3.00581, 7.2371, 8.68621, 6.32959, 2.56527,
		2.7061, 3.96953, 4.72786, 7.64122, 7.25534, 9.12661, 5.84915, 5.60761,
		6.23848, 0.972979, 6.64543, 7.82288, 8.86138, 1.33007, 0.449245,
		7.32532, 7.55094, 2.6337, 5.71869, 0.0168311, 9.33681, 1.36428, 1.36876,
		9.63792, 4.87584, 1.49069, 9.54176, 4.02105, 2.04715, 3.14823, 9.29554,
		1.01105, 6.9948, 5.2356, 7.15666, 6.35554, 8.74907, 9.70046, 6.70387,
		4.31074, 7.85953, 3.07188, 5.26658, 1.97118, 8.07167, 0.428748, 8.83147,
		3.73499, 8.31585, 7.88546, 1.31042, 3.36685, 6.53206, 7.77921, 9.72767,
		0.535825, 1.70103, 7.12735, 9.06349, 7.35048, 2.65697, 8.78209, 1.34411,
		6.03621, 8.44124, 5.97907, 4.34541, 3.36492, 1.26204, 8.2108, 6.39661,
		2.5333, 1.53193, 3.08059, 3.27109, 9.72108, 7.79339, 3.00709, 5.00246,
		2.27652, 1.52925, 8.3301, 0.729344, 7.31341, 5.99484, 1.90021, 1.73921,
		5.029, 5.85217, 2.73548, 3.28369, 8.80501, 9.08732, 3.86398, 3.85681,
		5.44288, 4.61538, 6.67404, 5.92569, 6.60679, 5.05477, 2.93707, 9.862,
		1.15997, 2.45729, 8.26317, 6.97511, 5.34172, 4.37512, 4.23744, 7.68162,
		1.89231, 6.30471, 8.71806, 6.28913, 6.81586, 0.763396, 9.43078, 4.24525,
		6.00109, 5.08563, 5.47886, 6.57699, 9.72986, 1.90437, 1.31524,
		0.0791747, 4.05654, 5.11967, 9.65602, 0.978221, 9.43854, 6.9291,
		0.0300941, 7.524, 4.56139, 3.54064, 4.0136, 7.21595, 5.89851, 4.64568,
		5.99674, 9.5567, 6.43801, 0.501445, 2.05129, 8.87073, 7.43821, 1.03053,
		1.30674, 4.08697, 0.885624, 7.88629, 5.96402, 6.71346, 9.39936, 2.02554,
		0.798783, 4.88443, 6.57235, 1.88325, 5.41404, 8.82631, 7.69632, 8.95348,
		4.14726, 6.01417, 8.49971, 2.68897, 9.68988, 6.33992, 0.277799, 8.60537,
		6.46699, 2.60259, 3.50909, 9.25453, 2.20126, 3.11728, 5.23982, 7.74362,
		9.69539, 2.7776, 8.42316, 6.68371, 5.17321, 3.70739, 4.59322, 8.29258,
		0.756906, 1.33319, 6.71565, 6.70722, 6.08408, 0.423518, 4.5335, 7.33993,
		3.46974, 5.48602, 2.98866, 9.09696, 7.77128, 9.67691, 2.43089, 6.40521,
		4.56784, 0.321243, 7.4327, 0.866662, 2.30386, 7.36176, 2.5235, 6.32961,
		3.00991, 2.52361, 9.0659, 0.55868, 0.376791, 5.60003, 3.69491, 9.38699,
		7.67588, 1.52649, 3.2078, 3.70436, 4.53697, 4.24531, 2.14975, 7.89115,
		5.7634, 1.27127, 3.85662, 7.44605, 7.64426, 9.41542, 1.11492, 6.61145,
		1.13798, 9.75362, 4.76476, 8.553, 9.63564, 4.82478, 9.14074, 3.86842,
		3.49678, 0.360855, 5.68277, 8.10473, 2.48209, 7.42172, 8.23379, 8.23511,
		1.81097, 7.02859, 9.71826, 0.77487, 0.107896, 3.92005, 6.49886, 2.95083,
		4.42748, 7.52129, 9.99684, 3.89783, 7.99446, 6.4865, 7.12858, 0.512549,
		2.25221, 2.01044, 0.796529, 8.67136, 9.56768, 2.33366, 9.29433, 4.01204,
		9.02803, 3.72461, 2.47912, 7.23997, 8.53587, 5.18235, 9.20441, 3.65277,
		5.4638, 7.67209, 3.79194, 0.272376, 2.5553, 3.50004, 5.37418, 2.95204,
		1.435, 7.13445, 0.730753, 7.94261, 4.47271, 3.82402, 8.96276, 9.02762,
		4.087, 8.85546, 9.85343, 3.52892, 5.10412, 2.52829, 9.87664, 8.2854,
		9.79342, 2.78097, 7.91599, 5.96311, 4.16, 8.6176, 3.06361, 3.06539,
		5.16143, 3.07833, 0.719396, 4.57794, 0.419737, 1.75952, 1.7865, 9.88122,
		8.04636, 6.29202, 5.12487, 2.94982, 1.2881, 6.25399, 6.4928, 9.85685,
		4.19535, 3.74882, 3.66864, 3.86369, 1.38217, 0.37919, 3.4529, 4.73716,
		1.82409, 3.68264, 0.308806, 2.25242, 3.49776, 6.36115, 4.59072, 4.80743,
		5.53555, 5.60239, 5.1992, 2.63322, 4.41311, 1.70656, 5.42647, 8.82998,
		6.89351, 5.89281, 4.0791, 2.53143, 3.28497, 5.27956, 1.6195, 8.0752,
		2.71704, 8.81146, 1.24118, 0.299691, 5.85733, 8.30366, 9.39727, 6.7798,
		7.46807, 1.63987, 9.56389, 3.46994, 1.92085, 1.27084, 2.40456, 8.26899,
		0.246206, 5.07977, 0.837385, 7.9299, 9.4057, 6.84943, 9.52276, 6.21178,
		6.03239, 9.74664, 0.784238, 4.996, 5.38891, 4.33148, 7.08258, 2.00983,
		9.00493, 4.54938, 3.83261, 3.71394, 7.59706, 6.17134, 3.85049, 8.38766,
		5.08822, 7.29997, 7.78871, 9.505, 1.30795, 1.52541, 4.51471, 3.43868,
		6.80131, 7.47493, 9.83688, 7.69449, 6.09369, 0.954256, 2.89627, 5.35795,
		6.31215, 9.17024, 3.82101, 1.28607, 3.00878, 3.464, 5.87772, 0.837151,
		8.56842, 4.98317, 2.01674, 2.03187, 0.633946, 4.42812, 6.89992,
		0.287809, 6.953, 9.81925, 0.0394211, 2.06595, 7.90862, 6.26726, 5.81871,
		5.11997, 6.53252, 7.2924, 7.49148, 3.6153, 7.09622, 0.406149, 9.32317,
		5.01862, 9.43857, 6.57294, 0.710482, 8.77381, 3.32509, 6.33437, 5.84748,
		4.42799, 3.79768, 9.01271, 3.23894, 5.23437, 4.63121, 2.86611, 5.31019,
		2.65251, 3.95998, 8.14331, 9.58197, 7.79172, 2.90845, 5.16345, 9.71711,
		1.04065, 3.24933, 8.07491, 2.82913, 0.175715, 3.59671, 9.93112, 7.26892,
		8.10842, 2.10193, 0.762154, 4.92827, 2.01637, 5.07728, 2.53166, 9.94966,
		5.12065, 5.41425, 4.72934, 7.18959, 2.49744, 8.10664, 7.91311, 6.36817,
		9.52017, 6.02503, 0.562944, 3.9219, 4.8985, 2.03598, 8.48962, 0.267663,
		0.0337882, 6.74744, 2.02039, 2.45019, 0.668125, 5.53929, 8.95303,
		9.63782, 8.56914, 0.0330613, 5.19544, 5.88886, 1.85516, 5.72062,
		6.38669, 6.60757, 7.34947, 8.73916, 9.73302, 3.2185, 9.94739, 8.14057,
		8.80578, 2.71914, 8.87857, 4.20851, 4.66684, 0.15445, };

#endif /* INPUT_CONSTANT_H_ */
