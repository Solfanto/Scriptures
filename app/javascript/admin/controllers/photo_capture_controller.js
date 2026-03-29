import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['fileInput', 'fileInputContainer', 'cameraPreview', 'video', 'canvas', 'takeButton', 'cancelButton', 'openCameraButton', 'photoDisplay', 'previewImage', 'existingPhotoImage', 'deleteButton', 'removeInput', 'switchCameraButton']
  static values = {
    fieldName: String
  }

  connect() {
    this.stream = null
    this.facingMode = 'environment' // Start with back camera
  }

  disconnect() {
    this.#stopCamera()
  }

  async checkCameraPermission() {
    // Check if Permissions API is available
    if (navigator.permissions && navigator.permissions.query) {
      try {
        const permissionStatus = await navigator.permissions.query({ name: 'camera' })
        return permissionStatus.state
      } catch (error) {
        // Permissions API might not support 'camera' name in all browsers
        // Fall back to trying to access the camera
        return null
      }
    }
    return null
  }

  async openCamera() {
    try {
      // Check if mediaDevices is available
      if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
        alert('Votre navigateur ne supporte pas l\'accès à la caméra. Veuillez utiliser un navigateur moderne.')
        return
      }

      // Check permission status first
      const permissionState = await this.checkCameraPermission()

      if (permissionState === 'denied') {
        alert('L\'accès à la caméra a été refusé. Veuillez autoriser l\'accès à la caméra dans les paramètres de votre navigateur ou de votre appareil (Réglages > Safari > Appareil photo).')
        return
      }

      // Attempt to access camera (this will prompt for permission if not granted)
      await this.startCamera(this.facingMode)
    } catch (error) {
      console.error('Error accessing camera:', error)

      let errorMessage = 'Impossible d\'accéder à la caméra.'

      if (error.name === 'NotAllowedError' || error.name === 'PermissionDeniedError') {
        errorMessage = 'L\'accès à la caméra a été refusé. Veuillez autoriser l\'accès à la caméra dans les paramètres de votre navigateur ou de votre appareil.\n\nSur iPhone/iPad : Réglages > Safari > Appareil photo\nSur Android : Paramètres > Applications > Chrome > Autorisations > Appareil photo'
      } else if (error.name === 'NotFoundError' || error.name === 'DevicesNotFoundError') {
        errorMessage = 'Aucune caméra n\'a été trouvée sur cet appareil.'
      } else if (error.name === 'NotReadableError' || error.name === 'TrackStartError') {
        errorMessage = 'La caméra est déjà utilisée par une autre application. Veuillez fermer les autres applications utilisant la caméra.'
      } else if (error.name === 'OverconstrainedError') {
        errorMessage = 'Les paramètres de la caméra ne sont pas supportés. Veuillez réessayer.'
      } else if (error.message) {
        errorMessage = `Erreur: ${error.message}`
      }

      alert(errorMessage)
    }
  }

  async startCamera(facingMode) {
    // Stop existing stream if any
    this.#stopCamera()

    // Small delay to ensure previous stream is fully stopped
    await new Promise(resolve => setTimeout(resolve, 100))

    // Request camera access with iOS-compatible constraints
    const constraints = {
      video: {
        facingMode: facingMode,
        width: { ideal: 720 },
        height: { ideal: 720 }
      }
    }

    // For iOS, we need to ensure the video element is ready
    this.videoTarget.setAttribute('playsinline', 'true')
    this.videoTarget.setAttribute('webkit-playsinline', 'true')
    this.videoTarget.muted = true

    this.stream = await navigator.mediaDevices.getUserMedia(constraints)

    this.facingMode = facingMode
    this.videoTarget.srcObject = this.stream

    // Wait for video metadata to load before playing
    await new Promise((resolve) => {
      this.videoTarget.onloadedmetadata = resolve
    })

    // Wait for video to be ready before playing
    try {
      await this.videoTarget.play()
    } catch (playError) {
      console.error('Error playing video:', playError)
      // On iOS, sometimes we need to wait a bit
      await new Promise(resolve => setTimeout(resolve, 100))
      await this.videoTarget.play()
    }

    // Show camera, hide file input and photo display
    this.cameraPreviewTarget.style.display = 'block'
    this.fileInputContainerTarget.style.display = 'none'
    this.photoDisplayTarget.style.display = 'none'
  }

  async switchCamera() {
    try {
      // Toggle between front and back camera
      const newFacingMode = this.facingMode === 'environment' ? 'user' : 'environment'
      await this.startCamera(newFacingMode)
    } catch (error) {
      console.error('Error switching camera:', error)
      alert('Impossible de changer de caméra.')
    }
  }

  takePhoto() {
    if (!this.videoTarget || !this.canvasTarget) {
      return
    }

    // Set canvas dimensions to match video
    this.canvasTarget.width = this.videoTarget.videoWidth
    this.canvasTarget.height = this.videoTarget.videoHeight

    // Draw video frame to canvas
    const context = this.canvasTarget.getContext('2d')
    context.drawImage(this.videoTarget, 0, 0)

    // Convert canvas to blob
    this.canvasTarget.toBlob((blob) => {
      if (blob) {
        // Create a File object from the blob
        const file = new File([blob], `photo_${Date.now()}.jpg`, { type: 'image/jpeg' })

        // Create a DataTransfer object to set the file
        const dataTransfer = new DataTransfer()
        dataTransfer.items.add(file)

        // Set the file to the file input
        this.fileInputTarget.files = dataTransfer.files

        // Trigger change event
        this.fileInputTarget.dispatchEvent(new Event('change', { bubbles: true }))

        // Show photo display with preview
        const imageUrl = URL.createObjectURL(blob)
        this.previewImageTarget.src = imageUrl
        this.previewImageTarget.style.display = 'block'

        // Hide existing photo image if present
        if (this.hasExistingPhotoImageTarget) {
          this.existingPhotoImageTarget.style.display = 'none'
        }

        // Show photo display, hide camera and file input
        this.photoDisplayTarget.style.display = 'block'
        this.cameraPreviewTarget.style.display = 'none'
        this.fileInputContainerTarget.style.display = 'none'

        // Stop camera
        this.#stopCamera()
      }
    }, 'image/jpeg', 0.9)
  }

  cancelCamera() {
    this.#stopCamera()
    // Show file input, hide camera
    this.cameraPreviewTarget.style.display = 'none'
    this.fileInputContainerTarget.style.display = 'block'
  }

  #stopCamera() {
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop())
      this.stream = null
    }

    if (this.videoTarget) {
      this.videoTarget.srcObject = null
      this.videoTarget.load() // Reset the video element
    }
  }

  handleFileChange(event) {
    const file = event.target.files[0]
    if (file) {
      // Show photo display with preview
      const imageUrl = URL.createObjectURL(file)
      this.previewImageTarget.src = imageUrl
      this.previewImageTarget.style.display = 'block'

      // Hide existing photo image if present
      if (this.hasExistingPhotoImageTarget) {
        this.existingPhotoImageTarget.style.display = 'none'
      }

      // Show photo display, hide file input
      this.photoDisplayTarget.style.display = 'block'
      this.fileInputContainerTarget.style.display = 'none'
    }
  }

  deletePhoto(event) {
    event.preventDefault()

    if (!confirm('Are you sure you want to delete this photo?')) {
      return
    }

    // Set remove flag
    if (this.hasRemoveInputTarget) {
      this.removeInputTarget.value = '1'
    }

    // Clear the file input
    if (this.hasFileInputTarget) {
      this.fileInputTarget.value = ''
    }

    // Hide preview image
    this.previewImageTarget.style.display = 'none'

    // Hide photo display, show file input
    this.photoDisplayTarget.style.display = 'none'
    this.fileInputContainerTarget.style.display = 'block'
  }
}
