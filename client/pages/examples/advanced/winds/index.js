import React from 'react'
import PT from 'prop-types'
import * as THREE from 'three'
import Promise from 'bluebird'
import droidSans from '-/assets/fonts/helvetiker_bold.typeface.json'

import Example from '-/components/example'

import notes from './readme.md'
import stationsData from './stations.json'
import threeOrbitControls from 'three-orbit-controls'

const globals = {
  stations: [],
  particles: {
    vertices: [],
  },
  fontLoader: new THREE.FontLoader(),
  font: null,
  colors: {
    stations: 0x4466ff,
    stationLabels: 0xffffff,
  },
}

/**
 * Create a station mesh object
 */
const createStation = (station) => {
  const stationGeom = new THREE.IcosahedronBufferGeometry(0.35, 0)
  const stationMat = new THREE.MeshPhongMaterial({
    color: globals.colors.stations,
  })
  const polyhedron = new THREE.Mesh(stationGeom, stationMat)
  const pos = calcPosFromLatLonRad(station.latitude, station.longitude, 30)
  polyhedron.position.set(...pos)
  return polyhedron
}

/**
 * Create a station mesh label
 */
const createStationLabel = (station) => {
  const textMat = new THREE.MeshPhongMaterial({
    color: globals.colors.stationLabels,
  })
  const defaultTextBufferGeomOpts = {
    size: 0.25,
    height: 0.25,
    curveSegments: 3,
    bevelEnabled: false,
  }
  const textGeom = new THREE.TextBufferGeometry(
    station.stationName,
    Object.assign({}, defaultTextBufferGeomOpts, {
      font: globals.font,
    })
  )
  const text = new THREE.Mesh(textGeom, textMat)
  const pos = calcPosFromLatLonRad(station.latitude, station.longitude, 30)
  text.position.set(...pos)
  return text
}

/**
 * Load the stations data into the given scene
 */
const loadStations = async (scene) => {
  const font = globals.fontLoader.parse(droidSans)
  globals.font = font

  const loadStations = stationsData.stations.map((s) => async () => {
    const station = createStation(s)
    const label = createStationLabel(s)
    scene.add(station)
    scene.add(label)
    globals.stations.push(station)
  })
  Promise.map(loadStations, (x) => Promise.resolve(x()).delay(100), {
    concurrency: 25,
  })
}

const loadParticles = async (scene) => {
  const particleCount = 1800
  const particleGeom = new THREE.Geometry()
  const particleMat = new THREE.PointsMaterial({
    color: 0xffffff,
    size: 0.5,
  })

  Array.from(new Array(particleCount).keys()).forEach(() => {
    const x = Math.random() * 150 - 75
    const y = Math.random() * 100 - 50
    const particle = new THREE.Vector3(x, y, 0)
    particleGeom.vertices.push(particle)
  })
  globals.particles = particleGeom

  const particles = new THREE.Points(particleGeom, particleMat)

  scene.add(particles)
}

/**
 * didMount()
 */
const init = ({ canvas }) => {
  console.log(canvas)
  // Create the scene and renderer
  const scene = new THREE.Scene()
  const renderer = new THREE.WebGLRenderer({ canvas })
  renderer.setSize(canvas.clientWidth, canvas.clientHeight)

  // Add the camera
  const camera = new THREE.PerspectiveCamera(
    75,
    canvas.clientWidth / canvas.clientHeight,
    1,
    100000
  )
  camera.position.z = 50

  const OrbitControls = threeOrbitControls(THREE)
  const controls = new OrbitControls(camera)
  controls.update()

  // Add the main light source
  const light = new THREE.PointLight(0xffffff, 2, 200)
  light.position.set(0, 40, 40)
  scene.add(light)

  let frame = 0
  const animate = () => {
    requestAnimationFrame(animate)

    globals.stations.forEach((p, i) => {
      p.rotation.x += 0.01
    })
    controls.update()

    globals.particles.vertices.forEach((p, i) => {
      const newPos = updateParticlePosition(p, frame)
      p.x = newPos.x
      p.y = newPos.y
    })
    globals.particles.verticesNeedUpdate = true

    renderer.render(scene, camera)
    frame += 0.1
  }
  animate()

  loadStations(scene)
  loadParticles(scene)

  return () => {
    scene.dispose()
    renderer.dispose()
  }
}

const updateParticlePosition = (pos, frame) => {
  const [x, y, z] = [
    pos.x + (Math.random() - 0.5) * 0.2,
    pos.y + (Math.random() - 0.5) * 0.2,
    pos.z,
  ]
  return new THREE.Vector3(x, y, z)
}

/**
 * Calculate a 3D position from a lat,lng pair and radius.
 */
// const calc3dPosFromLatLonRad = (lat, lon, radius) => {
//   const phi = (90 - lat) * (Math.PI / 180)
//   const theta = (lon + 180) * (Math.PI / 180)
//
//   const x = -(radius * Math.sin(phi) * Math.cos(theta))
//   const z = radius * Math.sin(phi) * Math.sin(theta)
//   const y = radius * Math.cos(phi)
//
//   return [x, y, z]
// }

/**
 * Calculate a 3D position from a lat,lng pair and radius
 */
const calcPosFromLatLonRad = (lat, lon, radius) => {
  const shift = Math.PI * radius
  const x = (lon * shift) / 180
  let y = Math.log(Math.tan(((90 + lat) * Math.PI) / 360)) / (Math.PI / 180)
  y = (y * shift) / 180

  return [x, y, 0]
}

const Winds = ({ color, id }) => {
  const canvas = React.useRef(null)
  console.log('effect')
  React.useEffect(() => {
    return init({ canvas: canvas.current })
  })
  return <canvas ref={canvas} />
}
Winds.propTypes = {
  color: PT.string,
  id: PT.string,
}

const E = () => (
  <div id="container">
    <Example notes={notes} components={{ Winds }} init={() => () => {}} />
  </div>
)

export default E
