from transformers import BertTokenizer, BertForSequenceClassification, Trainer, TrainingArguments
import pandas as pd
import torch

def train_transformer():
    # Dummy example: classify 'reason' from meta as up/down
    df = pd.read_csv('../../data/sample_market_data.csv')
    texts = ['momentum+news-spike', 'momentum', 'news-spike']
    labels = [1, 0, 1]
    tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')
    encodings = tokenizer(texts, truncation=True, padding=True)
    class DummyDataset(torch.utils.data.Dataset):
        def __init__(self, encodings, labels):
            self.encodings = encodings
            self.labels = labels
        def __getitem__(self, idx):
            item = {key: torch.tensor(val[idx]) for key, val in self.encodings.items()}
            item['labels'] = torch.tensor(self.labels[idx])
            return item
        def __len__(self):
            return len(self.labels)
    dataset = DummyDataset(encodings, labels)
    model = BertForSequenceClassification.from_pretrained('bert-base-uncased', num_labels=2)
    args = TrainingArguments(output_dir='./results', num_train_epochs=1, per_device_train_batch_size=2, logging_dir='./logs', logging_steps=10)
    trainer = Trainer(model=model, args=args, train_dataset=dataset)
    trainer.train()
    model.save_pretrained('transformer_model')
    print("Transformer model saved.")

if __name__ == "__main__":
    train_transformer()
