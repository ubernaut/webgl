import React from 'react'
import * as THREE from 'three'
import { css } from 'emotion'
import threeOrbitControls from 'three-orbit-controls'
import { MarchingCubes } from 'three/examples/jsm/objects/MarchingCubes'

import Example from '-/components/example'
import notes from './readme.md'

const BLACK = 0x000000
const WHITE = 0xffffff

const init = ({ canvas, container }) => {
  let scene = new THREE.Scene()
  scene.background = new THREE.Color(BLACK)

  const camera = new THREE.PerspectiveCamera(
    75,
    canvas.clientWidth / canvas.clientWidth,
    0.1,
    2000
  )
  camera.updateProjectionMatrix()
  camera.position.set(170, 0, 0)

  let renderer = new THREE.WebGLRenderer({ canvas, antialias: true })
  renderer.setSize(canvas.clientWidth, canvas.clientWidth)
  renderer.gammaOutput = true

  const OrbitControls = threeOrbitControls(THREE)
  const controls = new OrbitControls(camera, renderer.domElement)
  controls.enableDamping = true
  controls.update()

  // const light = new THREE.PointLight(WHITE, 5, 1000)
  // light.position.set(0, 100, 0)
  // light.castShadow = true
  // scene.add(light)
  const ambientLight = new THREE.AmbientLight(0x444444)
  scene.add(ambientLight)

  const spotLight = new THREE.SpotLight(WHITE, 5)
  spotLight.position.set(0, 100, 50)
  spotLight.castShadow = true
  spotLight.shadow.mapSize.width = 1024
  spotLight.shadow.mapSize.height = 1024
  spotLight.shadow.camera.near = 500
  spotLight.shadow.camera.far = 4000
  spotLight.shadow.camera.fov = 30
  scene.add(spotLight)

  const cubesMaterial = new THREE.MeshPhongMaterial({
    color: 0xffeeaa,
    opacity: 0.85,
    transparent: true,
    refractionRatio: 0.85,
    vertexColors: THREE.VertexColors,
  })
  const cubesInstance = new MarchingCubes(20, cubesMaterial, true, true)
  cubesInstance.position.set(0, 0, 0)
  cubesInstance.scale.set(100, 100, 100)
  cubesInstance.castShadow = true
  scene.add(cubesInstance)

  let thenSecs = 0
  const animate = (now) => {
    if (!renderer) {
      return
    }
    requestAnimationFrame(animate)
    const nowSecs = now * 0.001
    const deltaSecs = nowSecs - thenSecs
    thenSecs = nowSecs

    cubesInstance.reset()

    const x1 = 0.5 + Math.sin(nowSecs * 0.5) * 0.2
    const y1 = 0.25 + Math.cos(nowSecs * 0.5) * 0.25
    const z1 = 0.5
    cubesInstance.addBall(x1, y1, z1, 0.5, 12, new THREE.Color(0x6699ff))

    const x2 = 0.5 + Math.cos(nowSecs * 0.5) * 0.25
    const y2 = 0.25 + Math.sin(nowSecs * 0.5) * 0.25
    const z2 = 0.5
    cubesInstance.addBall(x2, y2, z2, 0.75, 12, new THREE.Color(0x99ff66))

    const x3 = 0.5
    const y3 = 0.25 + Math.cos(nowSecs * 0.5) * 0.25
    const z3 = 0.5
    cubesInstance.addBall(x3, y3, z3, 0.75, 12, new THREE.Color(0xff9966))

    const x4 = 0.5 + Math.cos(nowSecs * 0.5) * 0.25
    const y4 = 0.5
    const z4 = 0.25 + Math.sin(nowSecs * 0.5) * 0.25
    cubesInstance.addBall(x4, y4, z4, 0.75, 12, new THREE.Color(0xffff66))

    cubesInstance.addPlaneY(0.5, 12)
    cubesInstance.rotation.y += 0.01

    renderer.render(scene, camera)
  }
  animate()

  return () => {
    renderer.dispose()

    scene = null
    renderer = null
  }
}

const wrap = (Component, { ...first }) => ({ children, context, ...rest }) => (
  <Component {...first} {...rest}>
    {children}
  </Component>
)

const style = css`
  position: relative;
  .example-container {
    position: relative;
  }
`

const GraphingExample = () => (
  <div className={`${style} example-class`}>
    <Example notes={notes} init={init} />
  </div>
)

export default GraphingExample
