require 'gosu'
include Gl
include Glu

class ButterflyEffect < Gosu::Window
  def initialize
    super(800, 600, false)
    self.caption = 'Butterfly Effect'

    gl_init
    init_shaders
  end

  def gl_init
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  end

  def init_shaders
    @vertex_shader = compile_shader(GL_VERTEX_SHADER, vertex_shader_code)
    @fragment_shader = compile_shader(GL_FRAGMENT_SHADER, fragment_shader_code)
    @shader_program = glCreateProgram()

    glAttachShader(@shader_program, @vertex_shader)
    glAttachShader(@shader_program, @fragment_shader)
    glLinkProgram(@shader_program)
    glUseProgram(@shader_program)
  end

  def compile_shader(type, source)
    shader = glCreateShader(type)
    glShaderSource(shader, source)
    glCompileShader(shader)

    unless glGetShaderiv(shader, GL_COMPILE_STATUS) == GL_TRUE
      puts "Shader compilation failed:"
      puts glGetShaderInfoLog(shader)
      exit
    end

    shader
  end

  def vertex_shader_code
    <<~VERTEX_SHADER
      #version 330 core

      layout (location = 0) in vec3 aPos;

      void main()
      {
        gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
      }
    VERTEX_SHADER
  end

  def fragment_shader_code
    <<~FRAGMENT_SHADER
      #version 330 core

      out vec4 FragColor;

      void main()
      {
        FragColor = vec4(1.0, 1.0, 0.0, 1.0); // Yellow color, you can modify this
      }
    FRAGMENT_SHADER
  end

  def draw
    glClear(GL_COLOR_BUFFER_BIT)

    glBegin(GL_TRIANGLES)
    glVertex3f(-0.6, -0.5, 0.0)
    glVertex3f(0.6, -0.5, 0.0)
    glVertex3f(0.0, 0.5, 0.0)
    glEnd

    glUseProgram(0)
  end
end

ButterflyEffect.new.show
