package sandbox

import "adrastea"
import "adrastea/playdate/display"
import pd "adrastea/playdate"
import sys "adrastea/playdate/system"
import gfx "adrastea/playdate/graphics"
import "core:log"
import "core:time"

import rend "adrastea/renderer"

@(export)
eventHandler :: proc "c" (api: ^pd.Api, event: pd.System_Event, args: i32) -> i32 {
    context = pd.default_context()

    #partial switch event {
        case .init:
            adrastea.init(api)
            sys.set_update_callback(update)
            start()

        case .terminate: 
            shutdown()
    }
    return 0
}

// //////////////////////////////////
// //////////////////////////////////

mesh: adrastea.Mesh
timer: time.Stopwatch

vec3 :: [3]f32
vec3i :: [3]i16

verts: [3]vec3 
indices: [1]vec3i 
start :: proc() {
    verts = {
        {-0.5,   0.7,   0},
        {0.5,    0.5,   0},
        {0.0,    -0.5,    0},
    }
    indices = {
        {0, 1, 2},
    }

    mesh = adrastea.Mesh {verts[:], indices[:]}
    display.set_refresh_rate(50)
    rend.bound_render_target = rend.create_render_target(gfx.LCD_ROWSIZE * 8, gfx.LCD_ROWS)
}

shutdown :: proc() {
    rend.destroy_render_target(&rend.bound_render_target)
}


update :: proc() -> (should_update_display: bool) {
    // gfx.clear(gfx.Solid_Color.black)
    rend.clear_render_target(&rend.bound_render_target, 0)
    // rend.draw_mesh(&mesh)
    
    // Normal draw using row sweep
    // time.stopwatch_start(&timer)
    // for i in 0..<500{
    //     rend.draw_mesh(&mesh)
    // }
    // time.stopwatch_stop(&timer)
    // log.info("Frame time: ", time.stopwatch_duration(timer))
    // time.stopwatch_reset(&timer)
   
    // // Draw using bounds sweep 
    // time.stopwatch_start(&timer)
    // for i in 0..<500{
    //     rend.draw_mesh_bounds(&mesh)
    // }
    // time.stopwatch_stop(&timer)
    // log.info("Frame time: ", time.stopwatch_duration(timer))
    // time.stopwatch_reset(&timer)
    rend.draw_mesh(&mesh)

    // sys.draw_fps(0, 0)

    time.stopwatch_start(&timer)
    rend.present_render_target(&rend.bound_render_target)
    time.stopwatch_stop(&timer)
    log.info("Present time: ", time.stopwatch_duration(timer))
    time.stopwatch_reset(&timer)
    return false
}

