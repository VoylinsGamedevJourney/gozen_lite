#include "video.hpp"


void Video::open_video(String a_path) {

	// Allocate video file context
	av_format_ctx = avformat_alloc_context();
	if (!av_format_ctx) {
		UtilityFunctions::printerr("Couldn't allocate av format context!");
		return;
	}

	// Open file with avformat
	if (avformat_open_input(&av_format_ctx, a_path.utf8(), NULL, NULL)) {
		UtilityFunctions::printerr("Couldn't open video file!");
		close_video();
		return;
	}

	// Find stream information
	if (avformat_find_stream_info(av_format_ctx, NULL)) {
		UtilityFunctions::printerr("Couldn't find stream info!");
		close_video();
		return;
	}

	// Getting the audio and video stream
	for (int i = 0; i < av_format_ctx->nb_streams; i++) {
		AVCodecParameters* av_codec_params = av_format_ctx->streams[i]->codecpar;

		if (!avcodec_find_decoder(av_codec_params->codec_id))
			continue;
		else if (av_codec_params->codec_type == AVMEDIA_TYPE_AUDIO)
			av_stream_audio = av_format_ctx->streams[i];
		else if (av_codec_params->codec_type == AVMEDIA_TYPE_VIDEO)
			av_stream_video = av_format_ctx->streams[i];
	}

	// Video Decoder Setup 

	// Setup Decoder codec context
	const AVCodec* av_codec_video = avcodec_find_decoder(av_stream_video->codecpar->codec_id);
	if (!av_codec_video) {
		UtilityFunctions::printerr("Couldn't find any codec decoder for video!");
		close_video();
		return;
	}

	// Allocate codec context for decoder
	av_codec_ctx_video = avcodec_alloc_context3(av_codec_video);
	if (av_codec_ctx_video == NULL) {
		UtilityFunctions::printerr("Couldn't allocate codec context for video!");
		close_video();
		return;
	}

	// Copying parameters
	if (avcodec_parameters_to_context(av_codec_ctx_video, av_stream_video->codecpar)) {
		UtilityFunctions::printerr("Couldn't initialize video codec context!");
		close_video();
		return;
	}

	// Open codecs
	if (avcodec_open2(av_codec_ctx_video, av_codec_video, NULL)) {
		UtilityFunctions::printerr("Couldn't open video codec!");
		close_video();
		return;
	}


	// Audio Decoder Setup 

	// Setup Decoder codec context
	const AVCodec* av_codec_audio = avcodec_find_decoder(av_stream_audio->codecpar->codec_id);
	if (!av_codec_audio) {
		UtilityFunctions::printerr("Couldn't find any codec decoder for audio!");
		close_video();
		return;
	}

	// Allocate codec context for decoder
	av_codec_ctx_audio = avcodec_alloc_context3(av_codec_audio);
	if (av_codec_ctx_audio == NULL) {
		UtilityFunctions::printerr("Couldn't allocate codec context for audio!");
		close_video();
		return;
	}

	// Copying parameters
	if (avcodec_parameters_to_context(av_codec_ctx_audio, av_stream_audio->codecpar)) {
		UtilityFunctions::printerr("Couldn't initialize audio codec context!");
		close_video();
		return;
	}

	// Open codecs
	if (avcodec_open2(av_codec_ctx_audio, av_codec_audio, NULL)) {
		UtilityFunctions::printerr("Couldn't open audio codec!");
		close_video();
		return;
	}

	UtilityFunctions::print("Working!");
	is_open = true;
}


void Video::close_video() {
	is_open = false;

	if (av_format_ctx)
		avformat_close_input(&av_format_ctx);

	if (av_codec_ctx_video)
		avcodec_free_context(&av_codec_ctx_video);
	if (av_codec_ctx_audio)
		avcodec_free_context(&av_codec_ctx_audio);
}

