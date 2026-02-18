# Telex AI Block Authoring

This skill covers working with Telex, Automattic's AI-powered Gutenberg block authoring tool, including the artefact system, S3/MinIO integration, WordPress Playground, and development workflows.

## Overview

Telex is an AI-powered tool for creating custom Gutenberg blocks. It uses an "artefact system" to generate, iterate, and test blocks with S3-compatible storage (MinIO) and WordPress Playground for instant preview. Built with React/PHP, Node 22, and pnpm.

**Note**: This is a private repository requiring Automattic access. Special setup is required including MinIO, WordPress.com OAuth credentials, and Anthropic API keys.

## Repository Structure

### Core Architecture
```
telex/
├── src/                 # Main React application
│   ├── components/      # React components
│   ├── hooks/           # Custom React hooks
│   ├── services/        # API and external services
│   └── utils/           # Utility functions
├── server/              # Node.js backend
│   ├── api/             # API routes
│   ├── artefacts/       # Artefact management
│   ├── playground/      # WordPress Playground integration
│   └── storage/         # S3/MinIO storage
├── public/              # Static assets
└── docker/              # Docker configuration for MinIO
```

## Prerequisites and Setup

### Required Tools and Credentials
1. **Docker Desktop** — Required for MinIO (S3 storage)
2. **MinIO** — S3-compatible storage for artefacts
3. **WordPress.com OAuth credentials** — For authentication
4. **Anthropic API key** — For AI block generation
5. **Node 22** and pnpm

### Development Setup
```bash
cd repos/telex
source ~/.nvm/nvm.sh && nvm use
pnpm install

# Required: Start MinIO first
pnpm run minio:start

# Then start development server
pnpm run dev  # → http://localhost:3000
```

### MinIO Configuration
MinIO provides S3-compatible storage for artefacts:

```bash
# Start MinIO container
pnpm run minio:start

# MinIO admin interface: http://localhost:9001
# Access Key: minioadmin
# Secret Key: minioadmin
```

## Artefact System

### What are Artefacts?
Artefacts are the core concept in Telex — they represent generated blocks with:
- **Generated code** (JavaScript, PHP, CSS)
- **Metadata** (description, author, creation date)
- **Versions** (iteration history)
- **Preview data** (screenshots, demo content)

### Artefact Structure
```javascript
const artefact = {
  id: 'unique-id',
  name: 'My Custom Block',
  description: 'A block that does something useful',
  author: 'user-id',
  created: '2026-02-18T10:00:00Z',
  updated: '2026-02-18T11:30:00Z',
  versions: [
    {
      version: '1.0.0',
      files: {
        'block.js': 'JavaScript content...',
        'block.php': 'PHP content...',
        'style.css': 'CSS content...',
      },
      metadata: {
        prompt: 'Create a testimonial block with ratings',
        generated_at: '2026-02-18T10:00:00Z',
        ai_model: 'claude-3-5-sonnet',
      }
    }
  ],
  storage: {
    s3_key: 'artefacts/unique-id/',
    preview_url: 'https://playground.wordpress.net/?artefact=unique-id',
  }
};
```

### Artefact Lifecycle
1. **Generation** — AI creates initial block code
2. **Storage** — Files uploaded to S3/MinIO
3. **Preview** — Block tested in WordPress Playground
4. **Iteration** — User requests modifications, new version created
5. **Export** — Final block packaged for use

## AI Block Generation

### Prompt Engineering
Telex uses structured prompts to generate blocks:

```javascript
const blockPrompt = {
  description: 'Create a testimonial block with star ratings',
  features: [
    'Editable testimonial text',
    '5-star rating system',
    'Author name and photo',
    'Responsive design'
  ],
  style: 'modern, clean design with subtle shadows',
  behavior: 'Static block (no dynamic content)',
};

// Send to AI service
const generatedBlock = await aiService.generateBlock(blockPrompt);
```

### Generated Block Structure
AI generates complete Gutenberg blocks:

```javascript
// Generated block.js
import { registerBlockType } from '@wordpress/blocks';
import { useBlockProps, InspectorControls, RichText } from '@wordpress/block-editor';
import { PanelBody, RangeControl } from '@wordpress/components';

registerBlockType('telex/testimonial', {
  title: 'Testimonial',
  category: 'text',
  attributes: {
    testimonial: { type: 'string' },
    author: { type: 'string' },
    rating: { type: 'number', default: 5 },
  },
  
  edit: ({ attributes, setAttributes }) => {
    const blockProps = useBlockProps();
    
    return (
      <>
        <InspectorControls>
          <PanelBody title="Rating">
            <RangeControl
              label="Star Rating"
              value={attributes.rating}
              onChange={(rating) => setAttributes({ rating })}
              min={1}
              max={5}
            />
          </PanelBody>
        </InspectorControls>
        
        <div {...blockProps}>
          <RichText
            tagName="blockquote"
            value={attributes.testimonial}
            onChange={(testimonial) => setAttributes({ testimonial })}
            placeholder="Enter testimonial..."
          />
          <RichText
            tagName="cite"
            value={attributes.author}
            onChange={(author) => setAttributes({ author })}
            placeholder="Author name"
          />
          <div className="rating">
            {'★'.repeat(attributes.rating)}{'☆'.repeat(5 - attributes.rating)}
          </div>
        </div>
      </>
    );
  },
  
  save: ({ attributes }) => {
    const blockProps = useBlockProps.save();
    return (
      <div {...blockProps}>
        <blockquote>{attributes.testimonial}</blockquote>
        <cite>{attributes.author}</cite>
        <div className="rating">
          {'★'.repeat(attributes.rating)}{'☆'.repeat(5 - attributes.rating)}
        </div>
      </div>
    );
  },
});
```

## S3/MinIO Storage Integration

### File Storage
Artefacts are stored in S3-compatible storage:

```javascript
import AWS from 'aws-sdk';

const s3Client = new AWS.S3({
  endpoint: process.env.MINIO_ENDPOINT || 'http://localhost:9000',
  accessKeyId: process.env.MINIO_ACCESS_KEY || 'minioadmin',
  secretAccessKey: process.env.MINIO_SECRET_KEY || 'minioadmin',
  s3ForcePathStyle: true,
  signatureVersion: 'v4',
});

class ArtefactStorage {
  static async uploadArtefact(artefactId, files) {
    const uploadPromises = Object.entries(files).map(([filename, content]) => {
      return s3Client.upload({
        Bucket: 'telex-artefacts',
        Key: `${artefactId}/${filename}`,
        Body: content,
        ContentType: this.getContentType(filename),
      }).promise();
    });
    
    return Promise.all(uploadPromises);
  }
  
  static async downloadArtefact(artefactId) {
    const listResponse = await s3Client.listObjectsV2({
      Bucket: 'telex-artefacts',
      Prefix: `${artefactId}/`,
    }).promise();
    
    const downloadPromises = listResponse.Contents.map(async (object) => {
      const response = await s3Client.getObject({
        Bucket: 'telex-artefacts',
        Key: object.Key,
      }).promise();
      
      return {
        filename: object.Key.replace(`${artefactId}/`, ''),
        content: response.Body.toString(),
      };
    });
    
    return Promise.all(downloadPromises);
  }
}
```

### Storage Management
```javascript
// Artefact versioning in storage
class ArtefactVersionManager {
  static async createVersion(artefactId, version, files) {
    const versionKey = `${artefactId}/versions/${version}/`;
    
    const uploads = Object.entries(files).map(([filename, content]) => {
      return s3Client.upload({
        Bucket: 'telex-artefacts',
        Key: `${versionKey}${filename}`,
        Body: content,
        Metadata: {
          artefact_id: artefactId,
          version: version,
          created_at: new Date().toISOString(),
        },
      }).promise();
    });
    
    return Promise.all(uploads);
  }
  
  static async listVersions(artefactId) {
    const response = await s3Client.listObjectsV2({
      Bucket: 'telex-artefacts',
      Prefix: `${artefactId}/versions/`,
      Delimiter: '/',
    }).promise();
    
    return response.CommonPrefixes.map(prefix => 
      prefix.Prefix.split('/').slice(-2, -1)[0]
    );
  }
}
```

## WordPress Playground Integration

### Instant Block Testing
Telex integrates with WordPress Playground for immediate block testing:

```javascript
import { startPlaygroundWeb } from '@wp-playground/client';

class PlaygroundService {
  static async createPreview(artefactId) {
    // Start WordPress Playground instance
    const client = await startPlaygroundWeb({
      iframe: document.getElementById('playground-iframe'),
      remoteUrl: 'https://playground.wordpress.net/remote.html',
    });
    
    // Install block plugin
    const blockFiles = await ArtefactStorage.downloadArtefact(artefactId);
    await this.installBlockPlugin(client, blockFiles);
    
    // Create demo post with block
    await this.createDemoPost(client, artefactId);
    
    return client;
  }
  
  static async installBlockPlugin(client, files) {
    // Create plugin directory
    await client.writeFile('/wordpress/wp-content/plugins/telex-block/plugin.php', `
      <?php
      /**
       * Plugin Name: Telex Generated Block
       */
      
      function telex_block_init() {
          wp_enqueue_script(
              'telex-block',
              plugin_dir_url(__FILE__) . 'block.js',
              array('wp-blocks', 'wp-element', 'wp-editor'),
              '1.0.0'
          );
      }
      add_action('enqueue_block_editor_assets', 'telex_block_init');
    `);
    
    // Write block files
    for (const { filename, content } of files) {
      await client.writeFile(`/wordpress/wp-content/plugins/telex-block/${filename}`, content);
    }
    
    // Activate plugin
    await client.run({
      code: `<?php
        require_once '/wordpress/wp-load.php';
        activate_plugin('telex-block/plugin.php');
      ?>`
    });
  }
  
  static async createDemoPost(client, artefactId) {
    await client.run({
      code: `<?php
        require_once '/wordpress/wp-load.php';
        
        $post_id = wp_insert_post(array(
          'post_title' => 'Block Preview',
          'post_content' => '<!-- wp:telex/block-name {} /-->',
          'post_status' => 'publish',
          'post_type' => 'post'
        ));
        
        echo get_edit_post_link($post_id);
      ?>`
    });
  }
}
```

### Live Preview Updates
When blocks are modified, previews update in real-time:

```javascript
class LivePreview {
  static async updateBlock(artefactId, newFiles) {
    // Update storage
    await ArtefactStorage.uploadArtefact(artefactId, newFiles);
    
    // Update playground instance
    const playgroundClient = this.getPlaygroundClient(artefactId);
    
    // Write updated files to playground
    for (const [filename, content] of Object.entries(newFiles)) {
      await playgroundClient.writeFile(
        `/wordpress/wp-content/plugins/telex-block/${filename}`,
        content
      );
    }
    
    // Refresh editor to load new block code
    await playgroundClient.run({
      code: `<?php
        // Force refresh of block editor
        wp_enqueue_script('force-refresh', 'data:text/javascript,window.location.reload()');
      ?>`
    });
  }
}
```

## CLI and Development Tools

### Telex CLI Commands
```bash
# Generate a new block
pnpm telex generate "Create a pricing table block"

# Test an existing artefact
pnpm telex test <artefact-id>

# Export artefact as WordPress plugin
pnpm telex export <artefact-id> --format=plugin

# List all artefacts
pnpm telex list

# Start development server with MinIO
pnpm telex dev
```

### Development Workflow
```javascript
// Development mode workflow
class DevelopmentWorkflow {
  static async createBlock(prompt) {
    // 1. Generate block with AI
    const generatedCode = await aiService.generateBlock(prompt);
    
    // 2. Create artefact
    const artefact = await ArtefactManager.create({
      name: generatedCode.name,
      description: prompt,
      files: generatedCode.files,
    });
    
    // 3. Upload to storage
    await ArtefactStorage.uploadArtefact(artefact.id, generatedCode.files);
    
    // 4. Create playground preview
    const previewUrl = await PlaygroundService.createPreview(artefact.id);
    
    return {
      artefact,
      previewUrl,
    };
  }
  
  static async iterateBlock(artefactId, feedback) {
    // 1. Get current version
    const currentFiles = await ArtefactStorage.downloadArtefact(artefactId);
    
    // 2. Generate improvements
    const improvedCode = await aiService.improveBlock(currentFiles, feedback);
    
    // 3. Create new version
    await ArtefactVersionManager.createVersion(
      artefactId, 
      this.getNextVersion(artefactId),
      improvedCode.files
    );
    
    // 4. Update preview
    await LivePreview.updateBlock(artefactId, improvedCode.files);
    
    return improvedCode;
  }
}
```

## User Interface Components

### Block Generator
```javascript
import { useState } from 'react';
import { Button, TextArea, Card } from '../components/UI';

const BlockGenerator = () => {
  const [prompt, setPrompt] = useState('');
  const [isGenerating, setIsGenerating] = useState(false);
  
  const handleGenerate = async () => {
    setIsGenerating(true);
    try {
      const result = await DevelopmentWorkflow.createBlock(prompt);
      // Navigate to preview page
      navigate(`/artefacts/${result.artefact.id}`);
    } catch (error) {
      console.error('Generation failed:', error);
    } finally {
      setIsGenerating(false);
    }
  };
  
  return (
    <Card>
      <h2>Create New Block</h2>
      <TextArea
        value={prompt}
        onChange={setPrompt}
        placeholder="Describe the block you want to create..."
        rows={4}
      />
      <Button 
        onClick={handleGenerate} 
        disabled={!prompt || isGenerating}
      >
        {isGenerating ? 'Generating...' : 'Generate Block'}
      </Button>
    </Card>
  );
};
```

### Artefact Preview
```javascript
const ArtefactPreview = ({ artefactId }) => {
  const { data: artefact, isLoading } = useArtefact(artefactId);
  const [activeTab, setActiveTab] = useState('preview');
  
  if (isLoading) return <LoadingSpinner />;
  
  return (
    <div className="artefact-preview">
      <header>
        <h1>{artefact.name}</h1>
        <p>{artefact.description}</p>
      </header>
      
      <nav>
        <button 
          className={activeTab === 'preview' ? 'active' : ''}
          onClick={() => setActiveTab('preview')}
        >
          Preview
        </button>
        <button 
          className={activeTab === 'code' ? 'active' : ''}
          onClick={() => setActiveTab('code')}
        >
          Code
        </button>
        <button 
          className={activeTab === 'versions' ? 'active' : ''}
          onClick={() => setActiveTab('versions')}
        >
          Versions
        </button>
      </nav>
      
      <main>
        {activeTab === 'preview' && (
          <PlaygroundEmbed artefactId={artefactId} />
        )}
        {activeTab === 'code' && (
          <CodeEditor artefact={artefact} />
        )}
        {activeTab === 'versions' && (
          <VersionHistory artefactId={artefactId} />
        )}
      </main>
    </div>
  );
};
```

## API Integration

### Telex API Routes
```javascript
// Express.js API routes
const express = require('express');
const router = express.Router();

// Generate new block
router.post('/artefacts/generate', async (req, res) => {
  try {
    const { prompt } = req.body;
    const result = await DevelopmentWorkflow.createBlock(prompt);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Get artefact
router.get('/artefacts/:id', async (req, res) => {
  try {
    const artefact = await ArtefactManager.get(req.params.id);
    res.json(artefact);
  } catch (error) {
    res.status(404).json({ error: 'Artefact not found' });
  }
});

// Update artefact
router.put('/artefacts/:id', async (req, res) => {
  try {
    const { files, feedback } = req.body;
    const result = await DevelopmentWorkflow.iterateBlock(req.params.id, feedback);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
```

## Security and Authentication

### WordPress.com OAuth Integration
```javascript
import { OAuth2Strategy } from 'passport-oauth2';

const wpcomStrategy = new OAuth2Strategy({
  authorizationURL: 'https://public-api.wordpress.com/oauth2/authorize',
  tokenURL: 'https://public-api.wordpress.com/oauth2/token',
  clientID: process.env.WPCOM_CLIENT_ID,
  clientSecret: process.env.WPCOM_CLIENT_SECRET,
  callbackURL: '/auth/wpcom/callback',
}, async (accessToken, refreshToken, profile, done) => {
  // Handle user authentication
  const user = await UserService.findOrCreate(profile);
  return done(null, user);
});

passport.use(wpcomStrategy);
```

### Artefact Access Control
```javascript
class ArtefactSecurity {
  static async checkAccess(userId, artefactId, permission = 'read') {
    const artefact = await ArtefactManager.get(artefactId);
    
    // Owner has full access
    if (artefact.author === userId) {
      return true;
    }
    
    // Check shared permissions
    if (permission === 'read' && artefact.shared?.public) {
      return true;
    }
    
    // Check team access
    if (artefact.shared?.team?.includes(userId)) {
      return true;
    }
    
    return false;
  }
}
```

## Troubleshooting

### MinIO Connection Issues
```bash
# Check MinIO status
docker ps | grep minio

# Restart MinIO
pnpm run minio:stop
pnpm run minio:start

# Check MinIO logs
docker logs telex-minio
```

### Playground Integration Problems
- Ensure WordPress Playground is accessible
- Check network connectivity to playground.wordpress.net
- Verify block files are properly formatted
- Check browser console for JavaScript errors

### AI Generation Issues
- Verify Anthropic API key is set
- Check prompt clarity and specificity
- Review generated code for syntax errors
- Try regenerating with modified prompts

## Key Development Resources

- **WordPress Playground**: https://playground.wordpress.net/
- **Gutenberg Block Development**: https://developer.wordpress.org/block-editor/
- **MinIO Documentation**: https://docs.min.io/
- **Anthropic API**: https://docs.anthropic.com/
- **WordPress.com OAuth**: https://developer.wordpress.com/docs/oauth2/