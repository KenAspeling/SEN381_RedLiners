// File Upload Handler
const fileUploadHandler = async (req, res) => {
  try {
    const { file, user, topicId } = req;
    
    // Validate file type and size
    const validation = await validateFile(file);
    if (!validation.valid) {
      return res.status(400).json({ error: validation.message });
    }

    // Upload to cloud storage
    const uploadResult = await cloudinary.uploader.upload(file.path, {
      folder: `campuslearn/topics/${topicId}`,
      resource_type: 'auto'
    });

    // Save to database
    const fileRecord = await File.create({
      filename: uploadResult.public_id,
      originalName: file.originalname,
      url: uploadResult.secure_url,
      fileType: file.mimetype,
      size: file.size,
      uploadedBy: user.id,
      topicId: topicId
    });

    // Send notification to topic participants
    notificationService.notifyTopicUsers(
      topicId,
      'new_file',
      `${user.name} uploaded a new file: ${file.originalname}`
    );

    res.status(201).json({
      message: 'File uploaded successfully',
      file: fileRecord
    });
  } catch (error) {
    res.status(500).json({ error: 'Upload failed' });
  }
};
