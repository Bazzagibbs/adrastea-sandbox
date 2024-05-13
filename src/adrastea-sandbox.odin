package sandbox

import "adrastea"
import gfx "adrastea/graphics"
import "adrastea/playdate/display"
import pd "adrastea/playdate"
import pd_sys "adrastea/playdate/system"
import pd_gfx "adrastea/playdate/graphics"
import "core:log"
import "core:time"
import "core:runtime"

callback_ctx: runtime.Context

@(export)
eventHandler :: proc "c" (api: ^pd.Api, event: pd.System_Event, args: i32) -> i32 {

    #partial switch event {
        case .init:
            callback_ctx = pd.default_context()
            context = callback_ctx

            adrastea.init(api)
            adrastea.set_update_callback(update)
            start()

        case .terminate: 
            context = callback_ctx
            shutdown()
    }
    return 0
}


timer    : time.Stopwatch


// Shader =====================
Vertex_Attr :: struct {
    position : [3]f32,
    uv       : [2]i16,
}

Mat_Props :: struct {
    // Texture
}

Vertex_Out :: struct {
    position : [3]f32,
    uv       : [2]i16,
}
// ============================


shader   : gfx.Shader(Vertex_Attr, Mat_Props, Vertex_Out)
mesh     : gfx.Mesh(Vertex_Attr)
material : gfx.Material(type_of(shader))


start :: proc() {
    display.set_refresh_rate(50)

    // verts = {
    //     {-0.5,   0.7,   0},
    //     {0.5,    0.5,   0},
    //     {0.0,    -0.5,    0},
    // }
    // indices = {
    //     {0, 1, 2},
    // }

    shader = {

    }

}


shutdown :: proc() {
    gfx.render_pass_destroy(&render_pass)
}


update :: proc() -> (should_update_display: b32) {
    gfx.render_target_clear(&gfx.bound_render_target, 0)

    
    gfx.draw_mesh(&render_pass, &mesh, &material)


    time.stopwatch_start(&timer)
    gfx.present_render_target(&gfx.bound_render_target)
    time.stopwatch_stop(&timer)
    log.info("Present time: ", time.stopwatch_duration(timer))
    time.stopwatch_reset(&timer)

    pd_sys.draw_fps(0, 0)
    return true
}



// Shader test
vertex_main :: #force_inline proc "contextless" (v_in: Vertex_Attr, render_pass_props: ^gfx.Render_Pass_Property_Block, material_props: ^Mat_Props) -> (Vertex_Out) {
    vert := vec4 {v_in.x, v_in.y, v_in.z, 0}
    vert = vert * render_pass_props.mvp_mat

    return vert.xyz
}

