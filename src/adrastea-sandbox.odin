package sandbox

import "adrastea"
import "adrastea/playdate/display"
import pd "adrastea/playdate"
import pd_sys "adrastea/playdate/system"
import pd_gfx "adrastea/playdate/graphics"
import "core:log"
import "core:time"
import "core:runtime"

import rend "adrastea/renderer"

callback_ctx: runtime.Context

@(export)
eventHandler :: proc "c" (api: ^pd.Api, event: pd.System_Event, args: i32) -> i32 {

    #partial switch event {
        case .init:
            callback_ctx = pd.default_context()
            context = callback_ctx

            // adrastea.init(api)
            // adrastea.set_update_callback(update)
            pd.load_procs(api)
            pd_sys.set_update_callback(temp_update, &callback_ctx)
            // start()

        case .terminate: 
            // shutdown()
    }
    return 0
}

// //////////////////////////////////
// //////////////////////////////////

temp_update :: proc "c" (user_data: rawptr) -> i32 {
    context = (^runtime.Context)(user_data)^
    pd_sys.draw_fps(0, 0)
    return 1
}

// mesh: adrastea.Mesh
// timer: time.Stopwatch
//
// vec3 :: [3]f32
// vec3i :: [3]i16
//
// verts: [3]vec3 
// indices: [1]vec3i 
// start :: proc() {
//     verts = {
//         {-0.5,   0.7,   0},
//         {0.5,    0.5,   0},
//         {0.0,    -0.5,    0},
//     }
//     indices = {
//         {0, 1, 2},
//     }
//
//     mesh = adrastea.Mesh {verts[:], indices[:]}
//     display.set_refresh_rate(50)
//     rend.bound_render_target = rend.create_render_target(gfx.LCD_ROWSIZE * 8, gfx.LCD_ROWS)
// }
//
// shutdown :: proc() {
//     rend.destroy_render_target(&rend.bound_render_target)
// }
//
//
// // update :: proc() -> (should_update_display: bool) {
// update :: proc() -> (should_update_display: b32) {
//     // gfx.clear(gfx.Solid_Color.black)
//     rend.clear_render_target(&rend.bound_render_target, 0)
//     // rend.draw_mesh(&mesh)
//     
//     // Normal draw using row sweep
//     // time.stopwatch_start(&timer)
//     // for i in 0..<500{
//     //     rend.draw_mesh(&mesh)
//     // }
//     // time.stopwatch_stop(&timer)
//     // log.info("Frame time: ", time.stopwatch_duration(timer))
//     // time.stopwatch_reset(&timer)
//    
//     // // Draw using bounds sweep 
//     // time.stopwatch_start(&timer)
//     // for i in 0..<500{
//     //     rend.draw_mesh_bounds(&mesh)
//     // }
//     // time.stopwatch_stop(&timer)
//     // log.info("Frame time: ", time.stopwatch_duration(timer))
//     // time.stopwatch_reset(&timer)
//     rend.draw_mesh(&mesh)
//
//     // sys.draw_fps(0, 0)
//
//     time.stopwatch_start(&timer)
//     rend.present_render_target(&rend.bound_render_target)
//     time.stopwatch_stop(&timer)
//     log.info("Present time: ", time.stopwatch_duration(timer))
//     time.stopwatch_reset(&timer)
//     return true
// }
//
