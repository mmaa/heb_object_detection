# ObjectDetection

A live demo can be found at [heb-object-detection.fly.dev](https://heb-object-detection.fly.dev).

Please note that it's been tricky getting this to work smoothly in production with hosting on a free tier. The API response may be a 500, but the request may still go through successfully.

Try making the following request and then reloading the site.
```
POST https://heb-object-detection.fly.dev/images

{
  "label": "wind farm",
  "image_url": "https://imagga.com/static/images/tagging/wind-farm-538576_640.jpg",
  "object_detection_enabled": "true"
}
```

