---
name: reference_hls_endlist
description: VOD HLS playlists must end with EXT-X-ENDLIST or iOS Safari keeps polling the playlist as if it were live
metadata:
  type: reference
---

When generating an HLS playlist for VOD content, the final playlist must contain the
`#EXT-X-ENDLIST` tag. Without it, iOS Safari (and some smart-TV players) treat the stream as
live and keep re-polling the playlist every target-duration interval, which shows up as a
steady trickle of pointless requests in the CDN logs. Spec-level behavior — reproduces with
any HLS tooling in any environment.
