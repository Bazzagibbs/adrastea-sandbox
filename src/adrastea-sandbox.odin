package sandbox

import "adrastea"
import gfx "adrastea/graphics"
import "adrastea/playdate/display"
import pd "adrastea/playdate"
import pd_api "adrastea/playdate/bindings" // Used while Odin wrappers are being worked on
// import pd_sys "adrastea/playdate/system"
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
Mat_Props :: struct {
    // Texture
}

Vertex_Out :: struct {
    position  : [3]f32,
    tex_coord : [2]f32,
}
// ============================

main_target  : gfx.Render_Target
forward_pass : gfx.Render_Pass

shader       := gfx.shader_create(vertex_main, fragment_main)
material     := gfx.material_create(&shader, Mat_Props{})

mesh     : gfx.Mesh


start :: proc() {
    display.set_refresh_rate(50)

    main_target  = gfx.render_target_create(pd_api.LCD_ROWSIZE * 8, pd_api.LCD_ROWS, true)
    forward_pass = gfx.render_pass_create(&main_target)

    // verts = {
    //     {-0.5,   0.7,   0},
    //     {0.5,    0.5,   0},
    //     {0.0,    -0.5,    0},
    // }
    // indices = {
    //     {0, 1, 2},
    // }

}


shutdown :: proc() {
    gfx.render_pass_destroy(&forward_pass)
    gfx.render_target_destroy(&main_target)
}


update :: proc() -> (should_update_display: b32) {
    gfx.render_target_clear(&main_target, {})

    // Set up render pass transforms
    
    gfx.draw_mesh(&forward_pass, &mesh, &material)


    time.stopwatch_start(&timer)
    gfx.render_target_present(&main_target)
    time.stopwatch_stop(&timer)
    log.info("Present time: ", time.stopwatch_duration(timer))
    time.stopwatch_reset(&timer)

    pd_api.system.draw_fps(0, 0)
    return true
}



// Shader test
vertex_main :: proc "contextless" (v_in: gfx.Vertex_Attributes, render_pass_props: ^gfx.Render_Pass_Property_Block, material_props: ^Mat_Props) -> (v2f: Vertex_Out) {
    vert_pos: [4]f32
    vert_pos.xyz = v_in.position

    vert_pos = render_pass_props.mvp_mat * vert_pos

    v2f.position = vert_pos.xyz
    v2f.tex_coord = v_in.tex_coord
    return
}

fragment_main :: proc "contextless" (v2f: Vertex_Out, render_pass_props: ^gfx.Render_Pass_Property_Block, material_props: ^Mat_Props) -> (frag_out: gfx.Fragment) {
    frag_out.color = .black
    return
}

