local TweenFunction = {}

function TweenFunction.None(time)
    return time
end


function TweenFunction.EaseIn(time)
    return math.pow(time,2)
end
function TweenFunction.EaseOut(time)
    return math.pow(time,1/2)
end
function TweenFunction.EaseInOut(time)
    time = time * 2;
    if time < 1 then
        return 0.5 * math.pow(time, 2);
    else
        return 1.0 - 0.5 * math.pow(2 - time, 2);
    end
end


function TweenFunction.EaseExponentialIn(time)
    return time == 0 and 0 or math.pow(2, 10 * (time/1 - 1)) - 0.001;
end
function TweenFunction.EaseExponentialOut(time)
    return time == 1 and 1 or -math.pow(2, -10 * time / 1) + 1;
end
function TweenFunction.EaseExponentialInOut(time)
    time = time/0.5;
    if time < 1 then
        time = 0.5 * math.pow(2, 10 * (time - 1));
    else
        time = 0.5 * (-math.pow(2, -10 * (time - 1)) + 2);
    end
    return time;
end


function TweenFunction.EaseSineIn(time)
    return -1 * math.cos(time * math.pi/2) + 1;
end
function TweenFunction.EaseSineOut(time)
    return math.sin(time * math.pi/2);
end
function TweenFunction.EaseSineInOut(time)
    return -0.5 * (math.cos(math.pi * time) - 1);
end


function TweenFunction.EaseQuadraticActionIn(time)
    return   math.pow(time,2);
end
function TweenFunction.EaseQuadraticActionOut(time)
    return -time*(time-2);
end
function TweenFunction.EaseQuadraticActionInOut(time)
    local resultTime = time;
    time = time*2;
    if time < 1 then
        resultTime = time * time * 0.5;
    else
        time = time - 1
        resultTime = -0.5 * (time * (time - 2) - 1);
    end
    return resultTime;
end


function TweenFunction.EaseQuarticActionIn(time)
    return time * time * time * time;
end
function TweenFunction.EaseQuarticActionOut(time)
    time = time - 1;
    return -(time * time * time * time - 1);
end
function TweenFunction.EaseQuarticActionInOut(time)
    time = time*2;
    if time < 1 then
        return 0.5 * time * time * time * time;
    end
    time = time - 2;
    return -0.5 * (time * time * time * time - 2);
end


return TweenFunction