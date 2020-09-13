// https://developer.twitter.com/en/docs/twitter-api/v1/media/upload-media/uploading-media/media-best-practices

// Supported image media types: JPG, PNG, GIF, WEBP
// Image size <= 5 MB, animated GIF size <= 15 MB

// GIF
// Resolution should be <= 1280x1080 (width x height)
// Number of frames <= 350
// Number of pixels (width * height * num_frames) <= 300 million

#pragma once

#include <cstdint>
#include <cmath>

constexpr double_t ReductionRatio = 0.9;

constexpr size_t   ImgMaxSize   =  5 * 1024 * 1024;

constexpr size_t   GifMaxSize   = 15 * 1024 * 1024;
constexpr double_t GifMaxWidth  = 1280;
constexpr double_t GifMaxHeight = 1080;
constexpr double_t GifMaxFrames = 350;
constexpr double_t GifMaxPixels = 300 * 1000 * 1000;

constexpr size_t   BufferSize   = 16 * 1024;
