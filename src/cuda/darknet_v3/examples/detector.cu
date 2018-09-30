#include "darknet.h"
#include "DetectionGold.h"

static int coco_ids[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 14, 15, 16, 17,
		18, 19, 20, 21, 22, 23, 24, 25, 27, 28, 31, 32, 33, 34, 35, 36, 37, 38,
		39, 40, 41, 42, 43, 44, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
		58, 59, 60, 61, 62, 63, 64, 65, 67, 70, 72, 73, 74, 75, 76, 77, 78, 79,
		80, 81, 82, 84, 85, 86, 87, 88, 89, 90 };

void train_detector(char *datacfg, char *cfgfile, char *weightfile, int *gpus,
		int ngpus, int clear) {
	list *options = read_data_cfg(datacfg);
	char *train_images = option_find_str(options, "train", "data/train.list");
	char *backup_directory = option_find_str(options, "backup", "/backup/");

	srand(time(0));
	char *base = basecfg(cfgfile);
	printf("%s\n", base);
	real_t avg_loss = real_t(-1);
	network **nets = (network**) calloc(ngpus, sizeof(network));

	srand(time(0));
	int seed = rand();
	int i;
	for (i = 0; i < ngpus; ++i) {
		srand(seed);
#ifdef GPU
		cuda_set_device(gpus[i]);
#endif
		nets[i] = load_network(cfgfile, weightfile, clear);
		nets[i]->learning_rate *= ngpus;
	}
	srand(time(0));
	network *net = nets[0];

	int imgs = net->batch * net->subdivisions * ngpus;
	printf("Learning Rate: %g, Momentum: %g, Decay: %g\n", net->learning_rate,
			net->momentum, net->decay);
	data train, buffer;

	layer l = net->layers[net->n - 1];

	int classes = l.classes;
	real_t jitter = l.jitter;

	list *plist = get_paths(train_images);
	//int N = plist->size;
	char **paths = (char **) list_to_array(plist);

	load_args args = get_base_args(net);
	args.coords = l.coords;
	args.paths = paths;
	args.n = imgs;
	args.m = plist->size;
	args.classes = classes;
	args.jitter = jitter;
	args.num_boxes = l.max_boxes;
	args.d = &buffer;
	args.type = DETECTION_DATA;
	//args.type = INSTANCE_DATA;
	args.threads = 64;

	pthread_t load_thread = load_data(args);
	double time;
	int count = 0;
	//while(i*imgs < N*120){
	while (get_current_batch(net) < net->max_batches) {
		if (l.random && count++ % 10 == 0) {
			printf("Resizing\n");
			int dim = (rand() % 10 + 10) * 32;
			if (get_current_batch(net) + 200 > net->max_batches)
				dim = 608;
			//int dim = (rand() % 4 + 16) * 32;
			printf("%d\n", dim);
			args.w = dim;
			args.h = dim;

			pthread_join(load_thread, 0);
			train = buffer;
			free_data(train);
			load_thread = load_data(args);

#pragma omp parallel for
			for (i = 0; i < ngpus; ++i) {
				resize_network(nets[i], dim, dim);
			}
			net = nets[0];
		}
		time = what_time_is_it_now();
		pthread_join(load_thread, 0);
		train = buffer;
		load_thread = load_data(args);

		/*
		 int k;
		 for(k = 0; k < l.max_boxes; ++k){
		 box b = real_t_to_box(train.y.vals[10] + 1 + k*5);
		 if(!b.x) break;
		 printf("loaded: %f %f %f %f\n", b.x, b.y, b.w, b.h);
		 }
		 */
		/*
		 int zz;
		 for(zz = 0; zz < train.X.cols; ++zz){
		 image im = real_t_to_image(net->w, net->h, 3, train.X.vals[zz]);
		 int k;
		 for(k = 0; k < l.max_boxes; ++k){
		 box b = real_t_to_box(train.y.vals[zz] + k*5, 1);
		 printf("%f %f %f %f\n", b.x, b.y, b.w, b.h);
		 draw_bbox(im, b, 1, 1,0,0);
		 }
		 show_image(im, "truth11");
		 cvWaitKey(0);
		 save_image(im, "truth11");
		 }
		 */

		printf("Loaded: %lf seconds\n", what_time_is_it_now() - time);

		time = what_time_is_it_now();
		real_t loss = real_t(0);
#ifdef GPU
		if(ngpus == 1) {
			loss = train_network(net, train);
		} else {
			loss = train_networks(nets, ngpus, train, 4);
		}
#else
		loss = train_network(net, train);
#endif
		if (avg_loss < 0)
			avg_loss = loss;
		avg_loss = avg_loss * .9 + loss * .1;

		i = get_current_batch(net);
		printf("%ld: %f, %f avg, %f rate, %lf seconds, %d images\n",
				get_current_batch(net), loss, avg_loss, get_current_rate(net),
				what_time_is_it_now() - time, i * imgs);
		if (i % 100 == 0) {
#ifdef GPU
			if(ngpus != 1) sync_nets(nets, ngpus, 0);
#endif
			char buff[256];
			sprintf(buff, "%s/%s.backup", backup_directory, base);
			save_weights(net, buff);
		}
		if (i % 10000 == 0 || (i < 1000 && i % 100 == 0)) {
#ifdef GPU
			if(ngpus != 1) sync_nets(nets, ngpus, 0);
#endif
			char buff[256];
			sprintf(buff, "%s/%s_%d.weights", backup_directory, base, i);
			save_weights(net, buff);
		}
		free_data(train);
	}
#ifdef GPU
	if(ngpus != 1) sync_nets(nets, ngpus, 0);
#endif
	char buff[256];
	sprintf(buff, "%s/%s_final.weights", backup_directory, base);
	save_weights(net, buff);
}

static int get_coco_image_id(char *filename) {
	char *p = strrchr(filename, '/');
	char *c = strrchr(filename, '_');
	if (c)
		p = c;
	return atoi(p + 1);
}

static void print_cocos(FILE *fp, char *image_path, detection *dets,
		int num_boxes, int classes, int w, int h) {
	int i, j;
	int image_id = get_coco_image_id(image_path);
	for (i = 0; i < num_boxes; ++i) {
		real_t xmin = real_t(dets[i].bbox.x - dets[i].bbox.w / 2.);
		real_t xmax = real_t(dets[i].bbox.x + dets[i].bbox.w / 2.);
		real_t ymin = real_t(dets[i].bbox.y - dets[i].bbox.h / 2.);
		real_t ymax = real_t(dets[i].bbox.y + dets[i].bbox.h / 2.);

		if (xmin < 0)
			xmin = 0;
		if (ymin < 0)
			ymin = 0;
		if (xmax > w)
			xmax = w;
		if (ymax > h)
			ymax = h;

		real_t bx = xmin;
		real_t by = ymin;
		real_t bw = xmax - xmin;
		real_t bh = ymax - ymin;

		for (j = 0; j < classes; ++j) {
			if (dets[i].prob[j])
				fprintf(fp,
						"{\"image_id\":%d, \"category_id\":%d, \"bbox\":[%f, %f, %f, %f], \"score\":%f},\n",
						image_id, coco_ids[j], bx, by, bw, bh, dets[i].prob[j]);
		}
	}
}

void print_detector_detections(FILE **fps, char *id, detection *dets, int total,
		int classes, int w, int h) {
	int i, j;
	for (i = 0; i < total; ++i) {
		real_t xmin = real_t(dets[i].bbox.x - dets[i].bbox.w / 2. + 1);
		real_t xmax = real_t(dets[i].bbox.x + dets[i].bbox.w / 2. + 1);
		real_t ymin = real_t(dets[i].bbox.y - dets[i].bbox.h / 2. + 1);
		real_t ymax = real_t(dets[i].bbox.y + dets[i].bbox.h / 2. + 1);

		if (xmin < 1)
			xmin = 1;
		if (ymin < 1)
			ymin = 1;
		if (xmax > w)
			xmax = w;
		if (ymax > h)
			ymax = h;

		for (j = 0; j < classes; ++j) {
			if (dets[i].prob[j])
				fprintf(fps[j], "%s %f %f %f %f %f\n", id, dets[i].prob[j],
						xmin, ymin, xmax, ymax);
		}
	}
}

void print_imagenet_detections(FILE *fp, int id, detection *dets, int total,
		int classes, int w, int h) {
	int i, j;
	for (i = 0; i < total; ++i) {
		real_t xmin = real_t(dets[i].bbox.x - dets[i].bbox.w / 2.);
		real_t xmax = real_t(dets[i].bbox.x + dets[i].bbox.w / 2.);
		real_t ymin = real_t(dets[i].bbox.y - dets[i].bbox.h / 2.);
		real_t ymax = real_t(dets[i].bbox.y + dets[i].bbox.h / 2.);

		if (xmin < 0)
			xmin = 0;
		if (ymin < 0)
			ymin = 0;
		if (xmax > w)
			xmax = w;
		if (ymax > h)
			ymax = h;

		for (j = 0; j < classes; ++j) {
			int class_ = j;
			if (dets[i].prob[class_])
				fprintf(fp, "%d %d %f %f %f %f %f\n", id, j + 1,
						dets[i].prob[class_], xmin, ymin, xmax, ymax);
		}
	}
}

void validate_detector_flip(char *datacfg, char *cfgfile, char *weightfile,
		char *outfile) {
	int j;
	list *options = read_data_cfg(datacfg);
	char *valid_images = option_find_str(options, "valid", "data/train.list");
	char *name_list = option_find_str(options, "names", "data/names.list");
	char *prefix = option_find_str(options, "results", "results");
	char **names = get_labels(name_list);
	char *mapf = option_find_str(options, "map", 0);
	int *map = 0;
	if (mapf)
		map = read_map(mapf);

	network *net = load_network(cfgfile, weightfile, 0);
	set_batch_network(net, 2);
	fprintf(stderr, "Learning Rate: %g, Momentum: %g, Decay: %g\n",
			net->learning_rate, net->momentum, net->decay);
	srand(time(0));

	list *plist = get_paths(valid_images);
	char **paths = (char **) list_to_array(plist);

	layer l = net->layers[net->n - 1];
	int classes = l.classes;

	char buff[1024];
	char *type = option_find_str(options, "eval", "voc");
	FILE *fp = 0;
	FILE **fps = 0;
	int coco = 0;
	int imagenet = 0;
	if (0 == strcmp(type, "coco")) {
		if (!outfile)
			outfile = "coco_results";
		snprintf(buff, 1024, "%s/%s.json", prefix, outfile);
		fp = fopen(buff, "w");
		fprintf(fp, "[\n");
		coco = 1;
	} else if (0 == strcmp(type, "imagenet")) {
		if (!outfile)
			outfile = "imagenet-detection";
		snprintf(buff, 1024, "%s/%s.txt", prefix, outfile);
		fp = fopen(buff, "w");
		imagenet = 1;
		classes = 200;
	} else {
		if (!outfile)
			outfile = "comp4_det_test_";
		fps = (FILE**) calloc(classes, sizeof(FILE *));
		for (j = 0; j < classes; ++j) {
			snprintf(buff, 1024, "%s/%s%s.txt", prefix, outfile, names[j]);
			fps[j] = fopen(buff, "w");
		}
	}

	int m = plist->size;
	int i = 0;
	int t;

	real_t thresh = real_t(.005);
	real_t nms = real_t(.45);

	int nthreads = 4;
	image *val = (image*) calloc(nthreads, sizeof(image));
	image *val_resized = (image*) calloc(nthreads, sizeof(image));
	image *buf = (image*) calloc(nthreads, sizeof(image));
	image *buf_resized = (image*) calloc(nthreads, sizeof(image));
	pthread_t *thr = (pthread_t*) calloc(nthreads, sizeof(pthread_t));

	image input = make_image(net->w, net->h, net->c * 2);

	load_args args = { 0 };
	args.w = net->w;
	args.h = net->h;
	//args.type = IMAGE_DATA;
	args.type = LETTERBOX_DATA;

	for (t = 0; t < nthreads; ++t) {
		args.path = paths[i + t];
		args.im = &buf[t];
		args.resized = &buf_resized[t];
		thr[t] = load_data_in_thread(args);
	}
	double start = what_time_is_it_now();
	for (i = nthreads; i < m + nthreads; i += nthreads) {
		fprintf(stderr, "%d\n", i);
		for (t = 0; t < nthreads && i + t - nthreads < m; ++t) {
			pthread_join(thr[t], 0);
			val[t] = buf[t];
			val_resized[t] = buf_resized[t];
		}
		for (t = 0; t < nthreads && i + t < m; ++t) {
			args.path = paths[i + t];
			args.im = &buf[t];
			args.resized = &buf_resized[t];
			thr[t] = load_data_in_thread(args);
		}
		for (t = 0; t < nthreads && i + t - nthreads < m; ++t) {
			char *path = paths[i + t - nthreads];
			char *id = basecfg(path);
			copy_cpu(net->w * net->h * net->c, val_resized[t].data, 1,
					input.data, 1);
			flip_image(val_resized[t]);
			copy_cpu(net->w * net->h * net->c, val_resized[t].data, 1,
					input.data + net->w * net->h * net->c, 1);

			network_predict(net, input.data);
			int w = val[t].w;
			int h = val[t].h;
			int num = 0;
			detection *dets = get_network_boxes(net, w, h, thresh, real_t(.5),
					map, 0, &num);
			if (nms)
				do_nms_sort(dets, num, classes, nms);
			if (coco) {
				print_cocos(fp, path, dets, num, classes, w, h);
			} else if (imagenet) {
				print_imagenet_detections(fp, i + t - nthreads + 1, dets, num,
						classes, w, h);
			} else {
				print_detector_detections(fps, id, dets, num, classes, w, h);
			}
			free_detections(dets, num);
			free(id);
			free_image(val[t]);
			free_image(val_resized[t]);
		}
	}
	for (j = 0; j < classes; ++j) {
		if (fps)
			fclose(fps[j]);
	}
	if (coco) {
		fseek(fp, -2, SEEK_CUR);
		fprintf(fp, "\n]\n");
		fclose(fp);
	}
	fprintf(stderr, "Total Detection Time: %f Seconds\n",
			what_time_is_it_now() - start);
}

void validate_detector(char *datacfg, char *cfgfile, char *weightfile,
		char *outfile) {
	int j;
	list *options = read_data_cfg(datacfg);
	char *valid_images = option_find_str(options, "valid", "data/train.list");
	char *name_list = option_find_str(options, "names", "data/names.list");
	char *prefix = option_find_str(options, "results", "results");
	char **names = get_labels(name_list);
	char *mapf = option_find_str(options, "map", 0);
	int *map = 0;
	if (mapf)
		map = read_map(mapf);

	network *net = load_network(cfgfile, weightfile, 0);
	set_batch_network(net, 1);
	fprintf(stderr, "Learning Rate: %g, Momentum: %g, Decay: %g\n",
			net->learning_rate, net->momentum, net->decay);
	srand(time(0));

	list *plist = get_paths(valid_images);
	char **paths = (char **) list_to_array(plist);

	layer l = net->layers[net->n - 1];
	int classes = l.classes;

	char buff[1024];
	char *type = option_find_str(options, "eval", "voc");
	FILE *fp = 0;
	FILE **fps = 0;
	int coco = 0;
	int imagenet = 0;
	if (0 == strcmp(type, "coco")) {
		if (!outfile)
			outfile = "coco_results";
		snprintf(buff, 1024, "%s/%s.json", prefix, outfile);
		fp = fopen(buff, "w");
		fprintf(fp, "[\n");
		coco = 1;
	} else if (0 == strcmp(type, "imagenet")) {
		if (!outfile)
			outfile = "imagenet-detection";
		snprintf(buff, 1024, "%s/%s.txt", prefix, outfile);
		fp = fopen(buff, "w");
		imagenet = 1;
		classes = 200;
	} else {
		if (!outfile)
			outfile = "comp4_det_test_";
		fps = (FILE**) calloc(classes, sizeof(FILE *));
		for (j = 0; j < classes; ++j) {
			snprintf(buff, 1024, "%s/%s%s.txt", prefix, outfile, names[j]);
			fps[j] = fopen(buff, "w");
		}
	}

	int m = plist->size;
	int i = 0;
	int t;

	real_t thresh = real_t(.005);
	real_t nms = real_t(.45);

	int nthreads = 4;
	image *val = (image*) calloc(nthreads, sizeof(image));
	image *val_resized = (image*) calloc(nthreads, sizeof(image));
	image *buf = (image*) calloc(nthreads, sizeof(image));
	image *buf_resized = (image*) calloc(nthreads, sizeof(image));
	pthread_t *thr = (pthread_t*) calloc(nthreads, sizeof(pthread_t));

	load_args args = { 0 };
	args.w = net->w;
	args.h = net->h;
	//args.type = IMAGE_DATA;
	args.type = LETTERBOX_DATA;

	for (t = 0; t < nthreads; ++t) {
		args.path = paths[i + t];
		args.im = &buf[t];
		args.resized = &buf_resized[t];
		thr[t] = load_data_in_thread(args);
	}
	double start = what_time_is_it_now();
	for (i = nthreads; i < m + nthreads; i += nthreads) {
		fprintf(stderr, "%d\n", i);
		for (t = 0; t < nthreads && i + t - nthreads < m; ++t) {
			pthread_join(thr[t], 0);
			val[t] = buf[t];
			val_resized[t] = buf_resized[t];
		}
		for (t = 0; t < nthreads && i + t < m; ++t) {
			args.path = paths[i + t];
			args.im = &buf[t];
			args.resized = &buf_resized[t];
			thr[t] = load_data_in_thread(args);
		}
		for (t = 0; t < nthreads && i + t - nthreads < m; ++t) {
			char *path = paths[i + t - nthreads];
			char *id = basecfg(path);
			real_t *X = val_resized[t].data;
			network_predict(net, X);
			int w = val[t].w;
			int h = val[t].h;
			int nboxes = 0;
			detection *dets = get_network_boxes(net, w, h, thresh, real_t(.5),
					map, 0, &nboxes);
			if (nms)
				do_nms_sort(dets, nboxes, classes, nms);
			if (coco) {
				print_cocos(fp, path, dets, nboxes, classes, w, h);
			} else if (imagenet) {
				print_imagenet_detections(fp, i + t - nthreads + 1, dets,
						nboxes, classes, w, h);
			} else {
				print_detector_detections(fps, id, dets, nboxes, classes, w, h);
			}
			free_detections(dets, nboxes);
			free(id);
			free_image(val[t]);
			free_image(val_resized[t]);
		}
	}
	for (j = 0; j < classes; ++j) {
		if (fps)
			fclose(fps[j]);
	}
	if (coco) {
		fseek(fp, -2, SEEK_CUR);
		fprintf(fp, "\n]\n");
		fclose(fp);
	}
	fprintf(stderr, "Total Detection Time: %f Seconds\n",
			what_time_is_it_now() - start);
}

void validate_detector_recall(char *cfgfile, char *weightfile) {
	network *net = load_network(cfgfile, weightfile, 0);
	set_batch_network(net, 1);
	fprintf(stderr, "Learning Rate: %g, Momentum: %g, Decay: %g\n",
			net->learning_rate, net->momentum, net->decay);
	srand(time(0));

	list *plist = get_paths("data/coco_val_5k.list");
	char **paths = (char **) list_to_array(plist);

	layer l = net->layers[net->n - 1];

	int j, k;

	int m = plist->size;
	int i = 0;

	real_t thresh = real_t(.001);
	real_t iou_thresh = real_t(.5);
	real_t nms = real_t(.4);

	int total = 0;
	int correct = 0;
	int proposals = 0;
	real_t avg_iou = real_t(0);

	for (i = 0; i < m; ++i) {
		char *path = paths[i];
		image orig = load_image_color(path, 0, 0);
		image sized = resize_image(orig, net->w, net->h);
		char *id = basecfg(path);
		network_predict(net, sized.data);
		int nboxes = 0;
		detection *dets = get_network_boxes(net, sized.w, sized.h, thresh,
				real_t(.5), 0, 1, &nboxes);
		if (nms)
			do_nms_obj(dets, nboxes, 1, nms);

		char labelpath[4096];
		find_replace(path, "images", "labels", labelpath);
		find_replace(labelpath, "JPEGImages", "labels", labelpath);
		find_replace(labelpath, ".jpg", ".txt", labelpath);
		find_replace(labelpath, ".JPEG", ".txt", labelpath);

		int num_labels = 0;
		box_label *truth = read_boxes(labelpath, &num_labels);
		for (k = 0; k < nboxes; ++k) {
			if (dets[k].objectness > thresh) {
				++proposals;
			}
		}
		for (j = 0; j < num_labels; ++j) {
			++total;
			box t = { truth[j].x, truth[j].y, truth[j].w, truth[j].h };
			real_t best_iou = real_t(0);
			for (k = 0; k < l.w * l.h * l.n; ++k) {
				real_t iou = box_iou(dets[k].bbox, t);
				if (dets[k].objectness > thresh && iou > best_iou) {
					best_iou = iou;
				}
			}
			avg_iou += best_iou;
			if (best_iou > iou_thresh) {
				++correct;
			}
		}

		fprintf(stderr,
				"%5d %5d %5d\tRPs/Img: %.2f\tIOU: %.2f%%\tRecall:%.2f%%\n", i,
				correct, total, (real_t) proposals / (i + 1),
				avg_iou * 100 / total, 100. * correct / total);
		free(id);
		free_image(orig);
		free_image(sized);
	}
}

void test_detector(char *datacfg, char *cfgfile, char *weightfile,
		char *filename, real_t thresh, real_t hier_thresh, char *outfile,
		int fullscreen) {
	list *options = read_data_cfg(datacfg);
	char *name_list = option_find_str(options, "names", "data/names.list");
	char **names = get_labels(name_list);

	image **alphabet = load_alphabet();
	network *net = load_network(cfgfile, weightfile, 0);
	set_batch_network(net, 1);
	srand(2222222);
	double time;
	char buff[256];
	char *input = buff;
	real_t nms = real_t(.45);
//	printf("passou aqui\n");
	while (1) {
		if (filename) {
			strncpy(input, filename, 256);
		} else {
			printf("Enter Image Path: ");
			fflush (stdout);
			input = fgets(input, 256, stdin);
			if (!input)
				return;
			strtok(input, "\n");
		}

//		printf("passou aqui2\n");
		image im = load_image_color(input, 0, 0);

//		printf("passou aqui3\n");
		image sized = letterbox_image(im, net->w, net->h);
		//image sized = resize_image(im, net->w, net->h);
		//image sized2 = resize_max(im, net->w);
		//image sized = crop_image(sized2, -((net->w - sized2.w)/2), -((net->h - sized2.h)/2), net->w, net->h);
		//resize_network(net, sized.w, sized.h);
		layer l = net->layers[net->n - 1];

//		printf("passou aqui4\n");
		real_t *X = sized.data;

//		printf("passou aqui5\n");
		time = what_time_is_it_now();
		network_predict(net, X);
		printf("%s: Predicted in %f seconds.\n", input,
				what_time_is_it_now() - time);
		int nboxes = 0;
		detection *dets = get_network_boxes(net, im.w, im.h, thresh,
				hier_thresh, 0, 1, &nboxes);
		//printf("%d\n", nboxes);
		//if (nms) do_nms_obj(boxes, probs, l.w*l.h*l.n, l.classes, nms);
		if (nms)
			do_nms_sort(dets, nboxes, l.classes, nms);
		draw_detections(im, dets, nboxes, thresh, names, alphabet, l.classes);
		free_detections(dets, nboxes);
		if (outfile) {
			save_image(im, outfile);
		} else {
			save_image(im, "predictions");
#ifdef OPENCV
			cvNamedWindow("predictions", CV_WINDOW_NORMAL);
			if(fullscreen) {
				cvSetWindowProperty("predictions", CV_WND_PROP_FULLSCREEN, CV_WINDOW_FULLSCREEN);
			}
			show_image(im, "predictions", 0);
#endif
		}

		free_image(im);
		free_image(sized);
		if (filename)
			break;
	}
}

std::vector<std::pair<int, int> > load_all_images(std::vector<std::string> img_list, std::vector<image> *sized_images, network *net) {
	std::vector<std::pair<int, int> > original_sizes(img_list.size());

	int i = 0;
	for (auto s : img_list) {
		std::cout << s << "\n";
		image im = load_image_color(const_cast<char*>(s.c_str()), 0, 0);
		(*sized_images)[i] = letterbox_image(im, net->w, net->h);
		std::cout << i << " image pointer here " << im.data << "\n";
		original_sizes[i].first = im.w;
		original_sizes[i].second = im.h;

		i++;
		free_image(im);
	}

	return original_sizes;
}

void test_detector_radiation(char *datacfg, char *cfgfile, char *weightfile,
		char *filename, real_t thresh, real_t hier_thresh, char *outfile,
		int fullscreen, char **argv, int argc) {
	list *options = read_data_cfg(datacfg);
	char *name_list = option_find_str(options, "names", "data/names.list");
	char **names = get_labels(name_list);

	image **alphabet = load_alphabet();
	network *net = load_network(cfgfile, weightfile, 0);
	set_batch_network(net, 1);
	srand(2222222);
	double time;
	char buff[256];
	char *input = buff;
	real_t nms = real_t(.45);

	//--------------------------------------------------------------------
	printf("Executig radiation setup/test\n");
	DetectionGold detection_gold(argc, argv, thresh, hier_thresh, filename,
			cfgfile, datacfg, const_cast<char*>("detector"), weightfile);

	std::vector<image> sized_images(detection_gold.gold_img_names.size());

	std::vector<std::pair<int, int> > image_sizes = load_all_images(detection_gold.gold_img_names, &sized_images, net);

	// round counter for the images
	int count_image = -1;
	//--------------------------------------------------------------------
	std::cout << "passou depois\n";
	for (int iteration = 0; iteration < detection_gold.iterations;
			iteration++) {
		layer l = net->layers[net->n - 1];
		std::cout << "passou tambem\n";
		real_t *X = sized_images[count_image].data;

		std::cout << X << " x value\n";
		time = what_time_is_it_now();
		network_predict(net, X);
		printf("%s: Predicted in %f seconds.\n", input,
				what_time_is_it_now() - time);
		int nboxes = 0;

		int im_w = image_sizes[count_image].first;
		int im_h = image_sizes[count_image].second;
		detection *dets = get_network_boxes(net, im_w, im_h, thresh,
				hier_thresh, 0, 1, &nboxes);

		if (nms)
			do_nms_sort(dets, nboxes, l.classes, nms);

		// Test or compare the detections with the gold
		detection_gold.compare_or_generate(dets, nboxes, count_image, *net);

#ifdef DRAW
		draw_detections(im, dets, nboxes, thresh, names, alphabet, l.classes);

		if (outfile) {
			save_image(im, outfile);
		} else {
			save_image(im, "predictions");
#ifdef OPENCV
			cvNamedWindow("predictions", CV_WINDOW_NORMAL);
			if(fullscreen) {
				cvSetWindowProperty("predictions", CV_WND_PROP_FULLSCREEN, CV_WINDOW_FULLSCREEN);
			}
			show_image(im, "predictions", 0);
#endif
		}
#endif
		std::cout << "before free\n";
		free_detections(dets, nboxes);
		count_image = (count_image + 1) % detection_gold.gold_img_names.size();
		std::cout << "after free\n";
	}

	for (count_image = 0; count_image < sized_images.size(); count_image++) {
		free_image(sized_images[count_image]);
	}
}
/*
 void censor_detector(char *datacfg, char *cfgfile, char *weightfile, int cam_index, const char *filename, int class, real_t thresh, int skip)
 {
 #ifdef OPENCV
 char *base = basecfg(cfgfile);
 network *net = load_network(cfgfile, weightfile, 0);
 set_batch_network(net, 1);

 srand(2222222);
 CvCapture * cap;

 int w = 1280;
 int h = 720;

 if(filename){
 cap = cvCaptureFromFile(filename);
 }else{
 cap = cvCaptureFromCAM(cam_index);
 }

 if(w){
 cvSetCaptureProperty(cap, CV_CAP_PROP_FRAME_WIDTH, w);
 }
 if(h){
 cvSetCaptureProperty(cap, CV_CAP_PROP_FRAME_HEIGHT, h);
 }

 if(!cap) error("Couldn't connect to webcam.\n");
 cvNamedWindow(base, CV_WINDOW_NORMAL); 
 cvResizeWindow(base, 512, 512);
 real_t fps = 0;
 int i;
 real_t nms = .45;

 while(1){
 image in = get_image_from_stream(cap);
 //image in_s = resize_image(in, net->w, net->h);
 image in_s = letterbox_image(in, net->w, net->h);
 layer l = net->layers[net->n-1];

 real_t *X = in_s.data;
 network_predict(net, X);
 int nboxes = 0;
 detection *dets = get_network_boxes(net, in.w, in.h, thresh, 0, 0, 0, &nboxes);
 //if (nms) do_nms_obj(boxes, probs, l.w*l.h*l.n, l.classes, nms);
 if (nms) do_nms_sort(dets, nboxes, l.classes, nms);

 for(i = 0; i < nboxes; ++i){
 if(dets[i].prob[class] > thresh){
 box b = dets[i].bbox;
 int left  = b.x-b.w/2.;
 int top   = b.y-b.h/2.;
 censor_image(in, left, top, b.w, b.h);
 }
 }
 show_image(in, base);
 cvWaitKey(10);
 free_detections(dets, nboxes);


 free_image(in_s);
 free_image(in);


 real_t curr = 0;
 fps = .9*fps + .1*curr;
 for(i = 0; i < skip; ++i){
 image in = get_image_from_stream(cap);
 free_image(in);
 }
 }
 #endif
 }

 void extract_detector(char *datacfg, char *cfgfile, char *weightfile, int cam_index, const char *filename, int class, real_t thresh, int skip)
 {
 #ifdef OPENCV
 char *base = basecfg(cfgfile);
 network *net = load_network(cfgfile, weightfile, 0);
 set_batch_network(net, 1);

 srand(2222222);
 CvCapture * cap;

 int w = 1280;
 int h = 720;

 if(filename){
 cap = cvCaptureFromFile(filename);
 }else{
 cap = cvCaptureFromCAM(cam_index);
 }

 if(w){
 cvSetCaptureProperty(cap, CV_CAP_PROP_FRAME_WIDTH, w);
 }
 if(h){
 cvSetCaptureProperty(cap, CV_CAP_PROP_FRAME_HEIGHT, h);
 }

 if(!cap) error("Couldn't connect to webcam.\n");
 cvNamedWindow(base, CV_WINDOW_NORMAL); 
 cvResizeWindow(base, 512, 512);
 real_t fps = 0;
 int i;
 int count = 0;
 real_t nms = .45;

 while(1){
 image in = get_image_from_stream(cap);
 //image in_s = resize_image(in, net->w, net->h);
 image in_s = letterbox_image(in, net->w, net->h);
 layer l = net->layers[net->n-1];

 show_image(in, base);

 int nboxes = 0;
 real_t *X = in_s.data;
 network_predict(net, X);
 detection *dets = get_network_boxes(net, in.w, in.h, thresh, 0, 0, 1, &nboxes);
 //if (nms) do_nms_obj(boxes, probs, l.w*l.h*l.n, l.classes, nms);
 if (nms) do_nms_sort(dets, nboxes, l.classes, nms);

 for(i = 0; i < nboxes; ++i){
 if(dets[i].prob[class] > thresh){
 box b = dets[i].bbox;
 int size = b.w*in.w > b.h*in.h ? b.w*in.w : b.h*in.h;
 int dx  = b.x*in.w-size/2.;
 int dy  = b.y*in.h-size/2.;
 image bim = crop_image(in, dx, dy, size, size);
 char buff[2048];
 sprintf(buff, "results/extract/%07d", count);
 ++count;
 save_image(bim, buff);
 free_image(bim);
 }
 }
 free_detections(dets, nboxes);


 free_image(in_s);
 free_image(in);


 real_t curr = 0;
 fps = .9*fps + .1*curr;
 for(i = 0; i < skip; ++i){
 image in = get_image_from_stream(cap);
 free_image(in);
 }
 }
 #endif
 }
 */

/*
 void network_detect(network *net, image im, real_t thresh, real_t hier_thresh, real_t nms, detection *dets)
 {
 network_predict_image(net, im);
 layer l = net->layers[net->n-1];
 int nboxes = num_boxes(net);
 fill_network_boxes(net, im.w, im.h, thresh, hier_thresh, 0, 0, dets);
 if (nms) do_nms_sort(dets, nboxes, l.classes, nms);
 }
 */

void run_detector(int argc, char **argv) {
	char *prefix = find_char_arg(argc, argv, "-prefix", 0);
	real_t thresh = find_real_t_arg(argc, argv, "-thresh", real_t(.5));
	real_t hier_thresh = find_real_t_arg(argc, argv, "-hier", real_t(.5));
	int cam_index = find_int_arg(argc, argv, "-c", 0);
	int frame_skip = find_int_arg(argc, argv, "-s", 0);
	int avg = find_int_arg(argc, argv, "-avg", 3);
	if (argc < 4) {
		fprintf(stderr,
				"usage: %s %s [train/test/valid] [cfg] [weights (optional)]\n",
				argv[0], argv[1]);
		return;
	}
	char *gpu_list = find_char_arg(argc, argv, "-gpus", 0);
	char *outfile = find_char_arg(argc, argv, "-out", 0);
	int *gpus = 0;
	int gpu = 0;
	int ngpus = 0;
	if (gpu_list) {
		printf("%s\n", gpu_list);
		int len = strlen(gpu_list);
		ngpus = 1;
		int i;
		for (i = 0; i < len; ++i) {
			if (gpu_list[i] == ',')
				++ngpus;
		}
		gpus = (int*) calloc(ngpus, sizeof(int));
		for (i = 0; i < ngpus; ++i) {
			gpus[i] = atoi(gpu_list);
			gpu_list = strchr(gpu_list, ',') + 1;
		}
	} else {
		gpu = gpu_index;
		gpus = &gpu;
		ngpus = 1;
	}

	int clear = find_arg(argc, argv, "-clear");
	int fullscreen = find_arg(argc, argv, "-fullscreen");
	int width = find_int_arg(argc, argv, "-w", 0);
	int height = find_int_arg(argc, argv, "-h", 0);
	int fps = find_int_arg(argc, argv, "-fps", 0);
	//int class = find_int_arg(argc, argv, "-class", 0);

	char *datacfg = argv[3];
	char *cfg = argv[4];
	char *weights = (argc > 5) ? argv[5] : 0;
	char *filename = (argc > 6) ? argv[6] : 0;
	if (0 == strcmp(argv[2], "test"))
		test_detector(datacfg, cfg, weights, filename, thresh, hier_thresh,
				outfile, fullscreen);
	else if (0 == strcmp(argv[2], "test_radiation")) {
		test_detector_radiation(datacfg, cfg, weights, filename, thresh,
				hier_thresh, outfile, fullscreen, argv, argc);
	} else if (0 == strcmp(argv[2], "train"))
		train_detector(datacfg, cfg, weights, gpus, ngpus, clear);
	else if (0 == strcmp(argv[2], "valid"))
		validate_detector(datacfg, cfg, weights, outfile);
	else if (0 == strcmp(argv[2], "valid2"))
		validate_detector_flip(datacfg, cfg, weights, outfile);
	else if (0 == strcmp(argv[2], "recall"))
		validate_detector_recall(cfg, weights);
	else if (0 == strcmp(argv[2], "demo")) {
		list *options = read_data_cfg(datacfg);
		int classes = option_find_int(options, "classes", 20);
		char *name_list = option_find_str(options, "names", "data/names.list");
		char **names = get_labels(name_list);
		demo(cfg, weights, thresh, cam_index, filename, names, classes,
				frame_skip, prefix, avg, hier_thresh, width, height, fps,
				fullscreen);
	}
	//else if(0==strcmp(argv[2], "extract")) extract_detector(datacfg, cfg, weights, cam_index, filename, class, thresh, frame_skip);
	//else if(0==strcmp(argv[2], "censor")) censor_detector(datacfg, cfg, weights, cam_index, filename, class, thresh, frame_skip);
}