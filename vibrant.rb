require 'gosu'
require 'perlin_noise'
include Gl, Glu

class Vibrant < Gosu::Window
  def initialize
    super(800, 600, false)
    self.caption = 'Vibrant'
    initialize_opengl
    load_shaders
    initialize_perlin_noise
    initialize_light_sources
    initialize_camera
  end

  def initialize_opengl
    glClearColor(0.0, 0.0, 0.0, 0.0)
    glEnable(GL_DEPTH_TEST)
    glDepthFunc(GL_LEQUAL)
    glEnable(GL_LIGHTING)
    glEnable(GL_LIGHT0)
    glEnable(GL_LIGHT1)
  end

  def load_shaders
    @vertex_shader = load_shader(GL_VERTEX_SHADER, vertex_shader_code)
    @fragment_shader = load_shader(GL_FRAGMENT_SHADER, fragment_shader_code)

    @shader_program = glCreateProgram()
    glAttachShader(@shader_program, @vertex_shader)
    glAttachShader(@shader_program, @fragment_shader)
    glLinkProgram(@shader_program)
    glUseProgram(@shader_program)
  end

  def initialize_perlin_noise
    @noise_generator = Perlin::Noise.new(2)
  end

  def initialize_light_sources
    @light0_angle = 0.0
    @light1_angle = Math::PI / 4.0
  end

  def initialize_camera
    @camera_distance = 8.0
    @camera_angle = 0.0
  end

  def draw
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    gluPerspective(45.0, width / height, 0.1, 100.0)

    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity

    update_light_sources
    update_camera

    render_teapot
  end

  def update
    update_camera_movement
  end

  private

  def load_shader(type, source)
    shader = glCreateShader(type)
    glShaderSource(shader, source)
    glCompileShader(shader)
    shader
  end

  def vertex_shader_code
    <<-VERTEX_SHADER
      varying vec3 normal;
      varying vec3 fragPosition;
      varying vec3 lightDir0;
      varying vec3 lightDir1;
      varying vec3 viewDir;
      
      void main() {
        normal = normalize(gl_NormalMatrix * gl_Normal);
        fragPosition = vec3(gl_ModelViewMatrix * gl_Vertex);
        lightDir0 = normalize(vec3(gl_LightSource[0].position));
        lightDir1 = normalize(vec3(gl_LightSource[1].position));
        viewDir = normalize(-fragPosition);
        
        gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
        gl_TexCoord[0] = gl_MultiTexCoord0;
        gl_FrontColor = gl_Color;
      }
    VERTEX_SHADER
  end

  def fragment_shader_code
    <<-FRAGMENT_SHADER
      varying vec3 normal;
      varying vec3 fragPosition;
      varying vec3 lightDir0;
      varying vec3 lightDir1;
      varying vec3 viewDir;
      
      uniform float time;
      
      void main() {
        vec4 ambientColor = vec4(0.2, 0.2, 0.2, 1.0);
        vec4 diffuseColor = calculate_diffuse_color();
        vec4 specularColor = vec4(1.0, 1.0, 1.0, 1.0);
        vec4 emissiveColor = calculate_emissive_color();
        
        float ambientStrength = 0.2;
        float diffuseStrength = max(dot(normal, lightDir0) + dot(normal, lightDir1), 0.0);
        float specularStrength = calculate_specular_strength();
        
        vec4 ambient = ambientStrength * ambientColor;
        vec4 diffuse = diffuseStrength * diffuseColor;
        vec4 specular = specularStrength * specularColor;
        
        gl_FragColor = gl_FrontColor * (ambient + diffuse + specular) + emissiveColor;
      }
      
      vec4 calculate_diffuse_color() {
        float noiseValue = perlin_noise(vec2(time * 0.1, time * 0.1));
        return vec4(abs(sin(time + noiseValue)), abs(cos(time + noiseValue)), abs(sin(time - noiseValue)), 1.0);
      }
      
      vec4 calculate_emissive_color() {
        float pulsate = 0.5 + 0.5 * sin(time);
        float noiseValue = perlin_noise(vec2(time * 0.2, time * 0.2));
        return vec4(pulsate * abs(cos(time + noiseValue)), pulsate * abs(sin(time + noiseValue)), pulsate * abs(cos(time - noiseValue)), 1.0);
      }
      
      float calculate_specular_strength() {
        float shininess = 64.0;
        return pow(max(dot(reflect(-lightDir0, normal), viewDir), 0.0) + max(dot(reflect(-lightDir1, normal), viewDir), 0.0), shininess);
      }
      
      float perlin_noise(vec2 position) {
        return float(@noise_generator[position])
      }
    FRAGMENT_SHADER
  end

  def render_teapot
    glTranslatef(0.0, 0.0, -@camera_distance)
    glRotatef(@camera_angle, 0.0, 1.0, 0.0)

    glutSolidTeapot(1.0)
  end

  def update_light_sources
    @light0_angle += 0.02
    light0_x = 2.0 * Math.cos(@light0_angle)
    light0_y = 2.0 * Math.sin(@light0_angle)
    light0_z = 2.0 * Math.sin(@light0_angle)
    glLightfv(GL_LIGHT0, GL_POSITION, [light0_x, light0_y, light0_z, 1.0])
    glLightfv(GL_LIGHT0, GL_DIFFUSE, [0.8, 0.8, 0.8, 1.0])
    glLightfv(GL_LIGHT0, GL_SPECULAR, [1.0, 1.0, 1.0, 1.0])

    @light1_angle -= 0.03
    light1_x = 2.0 * Math.cos(@light1_angle)
    light1_y = 2.0 * Math.sin(@light1_angle)
    light1_z = 2.0 * Math.sin(@light1_angle)
    glLightfv(GL_LIGHT1, GL_POSITION, [light1_x, light1_y, light1_z, 1.0])
    glLightfv(GL_LIGHT1, GL_DIFFUSE, [0.6, 0.6, 0.6, 1.0])
    glLightfv(GL_LIGHT1, GL_SPECULAR, [0.8, 0.8, 0.8, 1.0])
  end

  def update_camera
    @camera_angle += 0.5
  end

  def update_camera_movement
    @camera_distance += 0.01
  end
end

Vibrant.new.show
