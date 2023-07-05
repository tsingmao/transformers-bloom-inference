gen-proto:
	mkdir -p inference_server/model_handler/grpc_utils/pb

	python -m grpc_tools.protoc -Iinference_server/model_handler/grpc_utils/proto --python_out=inference_server/model_handler/grpc_utils/pb --grpc_python_out=inference_server/model_handler/grpc_utils/pb inference_server/model_handler/grpc_utils/proto/generation.proto

	find inference_server/model_handler/grpc_utils/pb/ -type f -name "*.py" -print0 -exec sed -i -e 's/^\(import.*pb2\)/from . \1/g' {} \;

	touch inference_server/model_handler/grpc_utils/__init__.py
	touch inference_server/model_handler/grpc_utils/pb/__init__.py

	rm -rf inference_server/model_handler/grpc_utils/pb/*.py-e

bloom-7b1:
	TOKENIZERS_PARALLELISM=false \
	MODEL_NAME=/models/bloom-7b1 \
	MODEL_CLASS=AutoModelForCausalLM \
	DEPLOYMENT_FRAMEWORK=hf_accelerate \
	DTYPE=bf16 \
	MAX_INPUT_LENGTH=2048 \
	MAX_BATCH_SIZE=32 \
	CUDA_VISIBLE_DEVICES=0 \
	gunicorn -t 0 -w 1 -b 0.0.0.0:5000 inference_server.server:app --access-logfile - --access-logformat '%(h)s %(t)s "%(r)s" %(s)s %(b)s'
