json.name "Test"
json.description "Test"
json.updated_at @reels.map(&:updated_at).max
json.categories do
  json.array! %w[A B C].each_with_index.to_a do |category, i|
    json.name "Category #{category}"
    json.id i
    json.reels(@reels) do |reel|
      json.id reel.id
      json.name reel.name
      json.updated_at reel.updated_at
      json.clips(reel.clips) do |clip|
        json.id clip.id
        json.position clip.position
        json.name clip.video.filename
        json.updated_at clip.updated_at
        json.video rails_blob_path(clip.video)
      end
    end
  end
end

# {
#   "name": "test",
#   "description": "test",
#   "updated_at": "2021-01-01",
#   "categories": [
#     {
#       "name": "Category A",
#       "id": 1,
#       "reels": [
#         {
#           "id": 1,
#           "name": "Reel 1",
#           "description": "Reel 1 description",
#           "updated_at": "2021-01-01",
#           "clips": [
#             {
#               "id": 1,
#               "name": "Clip 1",
#               "description": "Clip 1 description",
#               "updated_at": "2021-01-01",
#               "video": "http://videoboard.lvh.me:3000/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MjMsInB1ciI6ImJsb2JfaWQifX0=--230823ae9ad78f9df845d12609d77fe101656978/Meade%20Tractor%20Cuts.mp4"
#             },
#             {
#               "id": 2,
#               "name": "Clip 2",
#               "description": "Clip 2 description",
#               "updated_at": "2021-01-02",
#               "video": "http://videoboard.lvh.me:3000/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MjQsInB1ciI6ImJsb2JfaWQifX0=--2147108bccf52c03980b4ed9fbc936d05393fa55/RT3062%20Rotary%20Tiller_JD67875.mp4"
#             },
#             {
#               "id": 3,
#               "name": "Clip 3",
#               "description": "Clip 3 description",
#               "updated_at": "2021-01-03",
#               "video": "http://videoboard.lvh.me:3000/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MjUsInB1ciI6ImJsb2JfaWQifX0=--18af39eb77a1b99fea2d5bcad492b8ee3fb8a287/Z975M%20EFI%20ZTrakT%20Mower_JD67373.mp4"
#             }
#           ]
#         },
#         {
#           "id": 2,
#           "name": "Reel 2",
#           "description": "Reel 2 description",
#           "updated_at": "2021-01-01T00:00:00Z",
#           "clips": [
#             {
#               "id": 1,
#               "name": "Clip 1",
#               "description": "Clip 1 description",
#               "updated_at": "2021-01-01",
#               "video": "http://videoboard.lvh.me:3000/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MjMsInB1ciI6ImJsb2JfaWQifX0=--230823ae9ad78f9df845d12609d77fe101656978/Meade%20Tractor%20Cuts.mp4"
#             }
#           ]
#         }
#       ]
#     },
#     { "name": "Category B", "id": 2, "reels": [{ "id": 2, "name": "Reel 2", "description": "Reel 2 description", "updated_at": "2021-01-01", "clips": [] }] },
#     { "name": "Category C", "id": 2, "reels": [{ "id": 2, "name": "Reel 2", "description": "Reel 2 description", "updated_at": "2021-01-01", "clips": [] }] }
#   ]
# }
