
type AnimationData = {
    Animation: Animation,
    Tracks: {[Animator]: AnimationTrack}
}
local animCache: {[string]: AnimationData} = {} 
local function Animation(animator: Animator, animationId: string): AnimationTrack
    local cache = animCache[animationId]
    if not cache then
        local anim = Instance.new("Animation")
        anim.Name = animationId
        anim.AnimationId = animationId
        anim.Parent = script
        cache = {
            Animation = anim,
            Tracks = {}
        }
        animCache[animationId] = cache
    end
    local track = cache.Tracks[animator]
    if not track then
        track = animator:LoadAnimation(cache.Animation)
        cache.Tracks[animator] = track
    end
    return track
end

return {
    Animation = Animation
}