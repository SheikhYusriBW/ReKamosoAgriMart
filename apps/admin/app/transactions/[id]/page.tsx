export default function TransactionDetailPage({ params }: { params: { id: string } }) {
  return (
    <div>
      <h1>Transaction Detail: {params.id}</h1>
    </div>
  );
}
