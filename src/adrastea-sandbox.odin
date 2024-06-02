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
import "base:runtime"
import "core:math/linalg"

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

shader       := gfx.shader_create(Mat_Props, vertex_main, fragment_main)
material     := gfx.material_create(&shader, Mat_Props{})

mesh     := gfx.Mesh {
    vertices = {
        gfx.Vertex_Attributes {
            position  = {-0.5,   0.7,   0},
            tex_coord = {0, 0},
        }, 
        gfx.Vertex_Attributes {
            position  = {0.5,    0.5,   0},
            tex_coord = {0, 1},
        }, 
        gfx.Vertex_Attributes {
            position = {0.0,    -0.5,    0},
            tex_coord = {1, 0},
        }, 
    },
    index_buffer = {
        {0, 1, 2},
    },
}

angle: f32

start :: proc() {
    display.set_refresh_rate(50)

    main_target  = gfx.render_target_create(pd_api.LCD_ROWSIZE * 8, pd_api.LCD_ROWS, true)
    forward_pass = gfx.render_pass_create(&main_target)

}


shutdown :: proc() {
    gfx.render_pass_destroy(&forward_pass)
    gfx.render_target_destroy(&main_target)
}


update :: proc() -> (should_update_display: b32) {
    angle += f32(time.duration_seconds(time.stopwatch_duration(timer))) * 10
    // log.info("angle:", angle)
    time.stopwatch_reset(&timer)
    time.stopwatch_start(&timer)

    gfx.render_target_clear(&main_target, .white)
    
    forward_pass.properties.model_mat = linalg.MATRIX4F32_IDENTITY
    forward_pass.properties.view_mat = linalg.matrix4_from_trs_f32({0, 0, 2}, linalg.QUATERNIONF32_IDENTITY, {1, 1, 1})
    forward_pass.properties.projection_mat = linalg.matrix4_perspective_f32(40, 16/9, 0.1, 0)
    forward_pass.properties.projection_mat = linalg.matrix_ortho3d_f32(-1, 1, -1, 1, 0.1, 100)
    // Note: pvm order, column major
    // forward_pass.properties.mvp_mat = forward_pass.properties.projection_mat * forward_pass.properties.view_mat * forward_pass.properties.model_mat
    forward_pass.properties.mvp_mat = forward_pass.properties.model_mat * forward_pass.properties.view_mat * forward_pass.properties.projection_mat 
    // forward_pass.properties.mv_mat = forward_pass.properties.view_mat * forward_pass.properties.model_mat


    // Set up render pass transforms


    gfx.draw_mesh(&forward_pass, &mesh, &material)


    gfx.render_target_present(&main_target)

    pd_api.system.draw_fps(0, 0)
    
    time.stopwatch_stop(&timer)
    // log.info("frame time:", time.stopwatch_duration(timer))
    return true
}



// Shader test
vertex_main :: proc "contextless" (v_in: gfx.Vertex_Attributes, render_pass_props: ^gfx.Render_Pass_Property_Block, material_props: ^Mat_Props) -> (v2f: gfx.Vertex_To_Fragment) {
    vert_pos: [4]f32
    vert_pos.xyz = v_in.position
    vert_pos.w = 1

    v2f.position = render_pass_props.mvp_mat * vert_pos
    v2f.tex_coord = v_in.tex_coord
    return
}

fragment_main :: proc "contextless" (v2f: gfx.Vertex_To_Fragment, face_normal: [3]f32, render_pass_props: ^gfx.Render_Pass_Property_Block, material_props: ^Mat_Props) -> (frag_out: gfx.Fragment) {
    // tex_coord := v2f.tex_coord * 100
    frag_out.color = .black
    return
}

