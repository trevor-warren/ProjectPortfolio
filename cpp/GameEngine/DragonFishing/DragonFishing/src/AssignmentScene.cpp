#include "AssignmentScene.h"

#include "Object.h"
#include "Model.h"
#include "Engine.h"
#include "GlowingSceneOperation.h"
#include "Textures.h"

namespace Scenes
{
	namespace Assignment1
	{
		struct Data
		{
			std::vector<std::shared_ptr<GraphicsEngine::Textures>> Buffers;
			std::shared_ptr<Engine::Object> Meshes;
			std::shared_ptr<GraphicsEngine::Model> Model;
			std::shared_ptr<GraphicsEngine::GlowingSceneOperation> DeferredPipeline;
			int SelectedBuffer = 0;

			//FrameBase* Screen;
		};

		Data* data = nullptr;

		void Initialize()
		{
			//data = new Data();

			//Handle<Engine::Object> root = Engine::Root();
			//Handle<Engine::Object> environments = root->GetByName("Environments");
			//Handle<Engine::Object> level = environments->GetByName<Engine::Object>("Level");
			//Handle<GraphicsEngine::GlowingSceneOperation> deferredPipeline = level->GetByName("GlowingSceneOperation");
			//
			////data->DeferredPipeline = deferredPipeline;
			//
			//Dimensions resolution = GraphicsEngine::FrameBuffer::WindowSize;
			//
			//Handle<GraphicsEngine::Texture> final = GraphicsEngine::Textures::Create(resolution.Width, resolution.Height, GL_LINEAR, GL_CLAMP_TO_EDGE, GL_FLOAT, GL_RGBA, GL_RGBA);
			//Handle<GraphicsEngine::FrameBuffer> output = GraphicsEngine::FrameBuffer::Create(resolution.Width, resolution.Height, final);
			//
			////data->Buffers.push_back(final);
			//
			//Handle<GraphicsEngine::FrameBuffer> sceneBuffer = data->DeferredPipeline->GetSceneBuffer();

			//if (sceneBuffer.IsNull())
			//	return;
			//
			//for (int i = 0; i < 7; ++i)
			//	data->Buffers.push_back(sceneBuffer->GetTexture(i));

			//data->Screen = new FrameBase();
			//data->Screen->SetSize(DeviceVector(0, float(resolution.Width), 0, float(resolution.Height)));
			//
			//Frame* container = new Frame();
			//
			//container->SetSizeAndPosition(
			//	DeviceVector(0.2f, 0, 0.4f, 0),
			//	DeviceVector(0, 0, 0.5f, 0)
			//);
			//container->Appearance.Color = 0x202020FF;
			//container->SetParent(data->Screen);
		}

		void Update(float delta)
		{
			//Programs::Screen->Use();
			//Programs::Screen->uvScale.Set(1, 1);
			//Programs::Screen->uvOffset.Set(0, 0);
			//Programs::Screen->blendTexture.Set(false);
			//Programs::Screen->textureColor.Set(RGBA(0xFFFFFFFF));
			//Programs::Screen->resolution.Set(Graphics::ActiveWindow->Resolution);
			//
			//data->Screen->Draw();
		}

		void Clean()
		{
			//delete data;
			//
			//data = nullptr;
		}
	}
}